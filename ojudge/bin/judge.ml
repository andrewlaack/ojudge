let command = "timeout 50 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --memory-swap=256MB --cpus 1 judge"

let getOldestPending () = 
  let pending = "/var/lib/ojudge/pending-review" in
  let older a b =
    match a, b with
    | None, x | x, None -> x
    | Some (t1, _, _), Some (t2, _, _) -> if t1 <= t2 then a else b
  in
  let rec scan_ids user acc = function
    | [] -> acc
    | id :: rest ->
        let path = Printf.sprintf "%s/%s/%s" pending user id in
        let mtime = (Unix.stat path).st_mtime in
        scan_ids user (older acc (Some (mtime, user, id))) rest
  in
  let rec scan_users acc = function
    | [] -> acc
    | user :: rest ->
        let ids = Array.to_list (Sys.readdir (pending ^ "/" ^ user)) in
        scan_users (scan_ids user acc ids) rest
  in
  match scan_users None (Array.to_list (Sys.readdir pending)) with
  | None -> None
  | Some (_, user, id) -> Some (user, id)


let readFile p = In_channel.with_open_bin p In_channel.input_all

let writeResults dir code =
  let names =
    List.sort compare (Array.to_list (Sys.readdir (dir ^ "/expected"))) in
  let verdict name =
    let actual = dir ^ "/outputs/" ^ name in
    let code =
      try int_of_string (String.trim (readFile
            (dir ^ "/outputs/" ^ Filename.remove_extension name ^ ".code")))
      with _ -> 0 in
    if code = 124 then "TIME LIMIT EXCEEDED"
    else if code = 137 then "MEMORY LIMIT EXCEEDED"
    else if code <> 0 then "RUNTIME ERROR"
    else if not (Sys.file_exists actual) then "MISSING"
    else if String.trim (readFile actual)
            = String.trim (readFile (dir ^ "/expected/" ^ name)) then "PASS"
    else "WRONG"
  in
  let lines = List.map (fun n -> (Filename.remove_extension n, verdict n)) names in
  let passed = List.length (List.filter (fun (_, v) -> v = "PASS") lines) in
  Out_channel.with_open_text (dir ^ "/results/results.txt") (fun oc ->
    if code = 124 then output_string oc "TIME LIMIT EXCEEDED\n";
    Printf.fprintf oc "%d/%d passed\n" passed (List.length lines);
    List.iter (fun (n, v) -> Printf.fprintf oc "%s: %s\n" n v) lines)


let judgeOldest () =
  match getOldestPending () with
  | None -> None
  | Some (user, id) ->
      let dir = Printf.sprintf "/var/lib/ojudge/submissions/%s/%s" user id in
      let cmd = Printf.sprintf "cd %s && %s > results/output.txt 2>&1"
                  (Filename.quote dir) command in
      print_endline ("Executing: " ^ cmd);
      let code = Sys.command cmd in
      (try writeResults dir code
       with e -> prerr_endline ("judging " ^ id ^ ": " ^ Printexc.to_string e));
      Sys.remove (Printf.sprintf "/var/lib/ojudge/pending-review/%s/%s" user id);
      Some code

let rec loopForever () =
  (match judgeOldest () with
   | None -> Unix.sleep 2
   | Some _ -> ());
  loopForever ()

let () = loopForever ()
