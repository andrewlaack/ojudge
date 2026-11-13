
let run = 
    "cat ex1.in | ./a.out"

let compile = 
    "ocamlopt nums.cmxa str.cmxa -pp camlp4o -unsafe main.ml"

let command = 
    "podman run --rm -it --network=none --memory=256MB --cpus 1 judge test"
