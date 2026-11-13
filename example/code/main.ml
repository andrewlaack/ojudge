let readNext () = Scanf.scanf " %d" (fun x -> x) in
let rec scanAll idx arr =
  if idx >= Array.length arr then ()
  else
    let next = readNext () in
    Array.set arr idx next;
    scanAll (idx + 1) arr
in
let solve arr =
  let soln = Array.make (Array.length arr) 0 in
  let rec acc idx =
    if idx = Array.length arr then 0
    else
      let best = acc (idx + 1) in
      if idx < Array.length arr - 1 && arr.(idx) <= arr.(idx + 1) then
        let () = soln.(idx) <- soln.(idx + 1) + 1 in
        max soln.(idx) best
      else
        let () = soln.(idx) <- 1 in
        max 1 best
  in
  acc 0
in
let numbers = readNext () in
let arr = Array.make numbers 0 in
let () = scanAll 0 arr in
print_int (solve arr);
print_newline ()
