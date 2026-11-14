(*
    There are buildings in front of you with heights [a_0,a_1,...,a_{n-1}], where a_i is an integer. Assume each building has a depth of 100 units, there is a 10 unit gap between each of them, they are all directly in front of you, and the ground is flat.

    The first building is 100 units in front of you, and your eyes are 6 units above ground level. How many buildings are visible?
*)

let readInt () = 
    Scanf.scanf " %d" (fun x -> x)
in

let readInts n = 
    let arr = Array.make n 0 in 
    let rec acc idx = 
        if idx >= n then () else (arr.(idx) <- readInt (); acc (idx+1))
    in acc 0; arr
in

(* we are 6 units tall *)
let angleFromEyeLevel height distance = 
    atan ((float_of_int (height - 6)) /. (float_of_int (distance)))
in
    
let solve nums = 
    let rec acc idx best = 
        if idx >= (Array.length nums) then 0 else 
            let currentAngle = angleFromEyeLevel nums.(idx) ((idx * 110) + 100)  in
                if currentAngle > best then 
                    1 + (acc (idx+1) currentAngle)
                else acc (idx+1) best
    in acc 0 0.
in

let n = readInt () in 
    let nums = readInts n in 
    print_int (solve nums); print_newline ()
