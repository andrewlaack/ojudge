let command = "timeout 50 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --cpus 1 judge"

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

let judgeOldest () =
  match getOldestPending () with
  | None -> None
  | Some (user, id) ->
      let dir = Printf.sprintf "/var/lib/ojudge/submissions/%s/%s" user id in
      let cmd = Printf.sprintf "cd %s && %s" (Filename.quote dir) command in
        let () =  print_endline ("Executing: " ^ cmd) in
      let code = Sys.command cmd in
      Sys.remove (Printf.sprintf "/var/lib/ojudge/pending-review/%s/%s" user id);
      Some code

let rec loopForever () =
  (match judgeOldest () with
   | None -> Unix.sleep 2
   | Some _ -> ());
  loopForever ()

let () = loopForever ()
