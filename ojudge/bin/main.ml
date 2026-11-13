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
    let () = mkdir ("/var/lib/ojudge/" ^ username ^ "/" ^ subId) in 
    let () = mkdir ("/var/lib/ojudge/" ^ username ^ "/" ^ subId ^ "/code") in 
    let () = mkdir ("/var/lib/ojudge/" ^ username ^ "/" ^ subId ^ "/inputs") in 
    let () = mkdir ("/var/lib/ojudge/" ^ username ^ "/" ^ subId ^ "/outputs") in 
             mkdir ("/var/lib/ojudge/" ^ username ^ "/" ^ subId ^ "/results")

let uuid () =
  Uuidm.to_string (Uuidm.v4_gen (Random.State.make_self_init ()) ())

(* TODO: Make sure username can't do traversals, and guard this *)

let handleSubmission (cgi : Netcgi.cgi) =
  let code = cgi#argument_value "code" in
      let username = cgi#argument_value "username" in
            let subId = uuid () in
            let () = setupSubmissionDir subId username in
                let () = writeFile ("/var/lib/ojudge/" ^ username ^ "/" ^ subId ^ "/code/main.ml") code in
                submissionReply cgi

let () = Netcgi_cgi.run handleSubmission
