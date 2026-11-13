#!/bin/sh

cd /code
ocamlopt nums.cmxa str.cmxa -unsafe main.ml
cat ex1.in | ./a.out
