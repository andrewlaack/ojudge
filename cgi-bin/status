#!/bin/sh
printf 'Content-Type: text/html; charset=utf-8\r\n\r\n'

sub=${PATH_INFO##*/}
rest=${PATH_INFO%/*}
user=${rest##*/}

dir=/var/lib/ojudge/submissions/$user/$sub

[ -d "$dir" ] || { echo "<p>No such submission</p>"; exit 0; }

show() {
    echo "<h2>$1</h2><pre>"
    sed 's/&/\&amp;/g; s/</\&lt;/g' "$2"
    echo "</pre>"
}

if [ -e "/var/lib/ojudge/pending-review/$user/$sub" ]; then
    echo '<meta http-equiv="refresh" content="3">'
    echo "<h1>Submission $sub: pending</h1>"
elif [ -e "$dir/results/results.txt" ]; then
    echo "<h1>Submission $sub: judged</h1>"
    show Results "$dir/results/results.txt"
    [ -s "$dir/results/output.txt" ] && show Output "$dir/results/output.txt"
else
    echo "<h1>Submission $sub: no results (judging failed?)</h1>"
fi
