#!/bin/sh
printf 'Content-Type: text/html; charset=utf-8\r\n\r\n'

id=${PATH_INFO##*/}

cat <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Submit code: $id</title>
</head>
<body>
    <h1>ojudge, submit code</h1>
    <p>Problem: <a href="/cgi-bin/problems/$id">$id</a></p>
    <div class="form-container">
        <form id="submit-code" action="/cgi-bin/submit-code/$id" method="post">
            <label for="username">Username</label><br>
            <input id="username" name="username" required><br>

            <label for="language">Language</label><br>
            <select name="language" id="language">
                <option value="ocaml">OCaml</option>
                <option value="c">C</option>
                <option value="cpp">C++</option>
            </select><br>

            <label for="code">Code</label><br>
            <textarea id="code" name="code" rows="20" cols="80"
                      spellcheck="false" required></textarea><br>
            <input type="submit" value="Submit">
        </form>
    </div>
</body>
</html>
EOF
