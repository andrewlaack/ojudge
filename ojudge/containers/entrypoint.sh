#!/bin/sh

cd /code
ocamlopt nums.cmxa str.cmxa -unsafe main.ml

INPUTS=$(ls | grep \\.in$)

for INPUT in $INPUTS; do
    BASE=${INPUT%.*}
    cat $INPUT | ./a.out > $BASE.sub.out
    diff $BASE.out $BASE.sub.out
done
