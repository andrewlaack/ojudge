#!/bin/sh
printf 'Content-Type: text/html; charset=utf-8\r\n\r\n'
cat <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Submit code</title>
</head>
<body>
    <h1>ojudge, submit code</h1>
    <div class="form-container">
        <h2>Code</h2>
        <form id="submit-code" action="submit-code" method="post">
            <label for="code">Code</label><br>

            <input id="username" name="username" rows="20" cols="80"
                      spellcheck="false" required></input><br>

              <select name="language" id="language">
                  <option value="ocaml">OCaml</option>
                  <option value="c">C</option>
                  <option value="cpp">C++</option>
              </select>

            <textarea id="code" name="code" rows="20" cols="80"
                      spellcheck="false" required></textarea><br>
            <input type="submit" value="Submit">
        </form>
    </div>
</body>
</html>
EOF
