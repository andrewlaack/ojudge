build-container:
	podman build containers -t judge
	cd / && podman save localhost/judge | sudo -u ojudge podman load

build-ocaml:
	cd ojudge && dune build
	cp ojudge/_build/default/bin/submissions.exe cgi-bin/submit-code
	chmod 755 cgi-bin/submit-code
run-container:
	cd example && \
	timeout 5 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --cpus 1 judge

run-judge: build-container
	getent group ojudge >/dev/null || sudo groupadd --system ojudge
	id ojudge >/dev/null 2>&1 || sudo useradd --system --create-home --gid ojudge ojudge
	grep -q '^ojudge:' /etc/subuid || sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ojudge
	sudo loginctl enable-linger ojudge
	sudo chgrp -R ojudge /var/lib/ojudge
	sudo chmod -R g+rwX /var/lib/ojudge
	cd ojudge && dune build
	sudo install -m 755 ojudge/_build/default/bin/judge.exe /usr/local/bin/ojudge-judge
	sudo install -m 644 ojudge-judge.service /etc/systemd/system/ojudge-judge.service
	sudo systemctl daemon-reload
	sudo systemctl enable ojudge-judge
	sudo systemctl restart ojudge-judge

build-cgi: build-ocaml
	mkdir -p cgi-bin
	cp scripts/home.sh cgi-bin/home
	cp scripts/submit.sh cgi-bin/submit


deploy-server: build-cgi
	sudo rm -rf /srv/http/cgi-bin
	sudo cp -r cgi-bin /srv/http/
	sudo cp lighttpd.conf /etc/lighttpd/lighttpd.conf

	# state directories
	sudo mkdir -p /var/lib/ojudge
	sudo mkdir -p /var/lib/ojudge/submissions
	sudo mkdir -p /var/lib/ojudge/pending-review
	sudo mkdir -p /var/lib/ojudge/problems
	sudo mkdir -p /var/lib/ojudge/contests
	sudo chown -R http:http /var/lib/ojudge

	# just in case
	sudo chown -R root:root /srv/http
	sudo chmod 755 /srv/http/cgi-bin
	sudo systemctl restart lighttpd
