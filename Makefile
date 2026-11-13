build-container:
	podman build containers -t judge

run-container:
	cd example && \
	timeout 5 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --cpus 1 judge

build-cgi:
	mkdir -p cgi-bin
	cp scripts/example.sh cgi-bin/example.sh
	cp scripts/home.sh cgi-bin/home.sh

deploy-server: build-cgi
	sudo rm -rf /srv/http/cgi-bin
	sudo cp -r cgi-bin /srv/http/
	sudo cp lighttpd.conf /etc/lighttpd/lighttpd.conf

	# just in case
	sudo chown -R root:root /srv/http
	sudo chmod 755 /srv/http/cgi-bin
	sudo systemctl restart lighttpd
