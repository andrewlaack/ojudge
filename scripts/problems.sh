#!/bin/sh

echo "Content-Type: text/html"
echo

id=${PATH_INFO##*/}

echo "<h1>Problem: $id</h1>"
cat "/var/lib/ojudge/problems/$id/problem.html"
