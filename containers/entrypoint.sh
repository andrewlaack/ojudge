#!/bin/sh

# copy out the main.ml file into the temp dir because otherwise
# the build command will leave behind a few artifacts, but I'd rather
# have the user code directory be read only.

cp code/main.ml /tmp
cd /tmp

ocamlopt nums.cmxa str.cmxa -unsafe main.ml -o /tmp/submission.out
chmod +x /tmp/submission.out

# ./code:/code ./inputs:/inputs ./outputs:/outputs

INPUTS=$(ls /inputs)

for INPUT in $INPUTS; do
    BASE=${INPUT%.*}
    cat /inputs/$INPUT | /tmp/submission.out > /outputs/$BASE.out
done
