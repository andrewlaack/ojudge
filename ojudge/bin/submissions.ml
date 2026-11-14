let copyFile src dst =
  let data = In_channel.with_open_bin src In_channel.input_all in
  Out_channel.with_open_bin dst (fun oc -> output_string oc data)

let copyDir src dst =
  Array.iter
    (fun name ->
      let s = Filename.concat src name in
      if not (Sys.is_directory s) then copyFile s (Filename.concat dst name))
    (Sys.readdir src)

let valid_id s =
  s <> ""
  && String.for_all
       (function '0'..'9'-> true | _ -> false)
       s

let () = ignore (Unix.umask 0o002)

let rec mkdir d =
  if not (Sys.file_exists d) then (mkdir (Filename.dirname d); Sys.mkdir d 0o775)

let submissionReply (cgi : Netcgi.cgi) username subId =
  cgi#set_header ~content_type:"text/html; charset=utf-8" ();
  let out = cgi#out_channel in
  out#output_string
    (Printf.sprintf
       "Your code has been submitted. <a href=\"/cgi-bin/status/%s/%s\">Check status</a>"
       username subId);
  out#commit_work ()

let writeFile filepath toWrite = 
    Out_channel.with_open_text filepath (fun oc -> output_string oc toWrite)

let setupSubmissionDir subId username = 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId) in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/code") in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/inputs") in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/outputs") in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/results") in
    mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/expected")

let uuid () =
  Uuidm.to_string (Uuidm.v4_gen (Random.State.make_self_init ()) ())

(* TODO: Make sure username can't do traversals, and guard this *)

let createCodeFile username subId code language = 
    if language = "ocaml" then
        writeFile ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/code/main.ml") code
    else
        if language = "cpp" then
        writeFile ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/code/main.cpp") code
    else 
        writeFile ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/code/main.c") code

let requestReview subId username = 
    mkdir ("/var/lib/ojudge/pending-review/" ^ username);
    writeFile ("/var/lib/ojudge/pending-review/" ^ username ^ "/" ^ subId) ""

let handleSubmission (cgi : Netcgi.cgi) =
  let problem = Filename.basename cgi#environment#cgi_path_info in
  let language = cgi#argument_value "language" in
  let code = cgi#argument_value "code" in
      let username = cgi#argument_value "username" in
            let subId = uuid () in
            let () = setupSubmissionDir subId username in
                    let () =  copyDir ("/var/lib/ojudge/problems/" ^ problem ^ "/inputs") ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/inputs") in
                        let () = copyDir ("/var/lib/ojudge/problems/" ^ problem ^ "/outputs") ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/expected") in
                        let () = createCodeFile username subId code language in
                            let () = requestReview subId username in 
                                submissionReply cgi username subId

let () = Netcgi_cgi.run handleSubmission
