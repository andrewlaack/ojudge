let rec mkdir d =
  if not (Sys.file_exists d) then (mkdir (Filename.dirname d); Sys.mkdir d 0o755)

let submissionReply (cgi : Netcgi.cgi) = 
      cgi#set_header ~content_type:"text/html; charset=utf-8" ();
      let out = cgi#out_channel in
      out#output_string (Printf.sprintf "Your code has been submitted. Please await judging.");
      out#commit_work ()

let writeFile filepath toWrite = 
    Out_channel.with_open_text filepath (fun oc -> output_string oc toWrite)

let setupSubmissionDir subId username = 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId) in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/code") in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/inputs") in 
    let () = mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/outputs") in 
             mkdir ("/var/lib/ojudge/submissions/" ^ username ^ "/" ^ subId ^ "/results")

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
  let language = cgi#argument_value "language" in
  let code = cgi#argument_value "code" in
      let username = cgi#argument_value "username" in
            let subId = uuid () in
            let () = setupSubmissionDir subId username in
                let () = createCodeFile username subId code language in
                    let () = requestReview subId username in 
                        submissionReply cgi

let () = Netcgi_cgi.run handleSubmission
