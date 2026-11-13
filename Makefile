build-container:
	podman build containers -t judge

build-ocaml:
	cd ojudge && dune build
	cp ojudge/_build/default/bin/main.exe cgi-bin/submit-code
	chmod 755 cgi-bin/submit-code
run-container:
	cd example && \
	timeout 5 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --cpus 1 judge

build-cgi: build-ocaml
	mkdir -p cgi-bin
	cp scripts/example.sh cgi-bin/example.sh
	cp scripts/home.sh cgi-bin/home.sh
	cp scripts/submit.sh cgi-bin/submit.sh


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
