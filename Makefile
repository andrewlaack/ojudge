build-container:
	podman build containers -t judge

run-container:
	cd example && \
	timeout 5 podman run --rm -v ./code:/code:ro -v ./inputs:/inputs:ro -v ./outputs:/outputs:rw --network=none --memory=256MB --cpus 1 judge
