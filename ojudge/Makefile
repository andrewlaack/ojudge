run-ocaml:
	dune exec ojudge

build-container:
	podman build containers -t judge

run-container:
	podman run --rm -it -v .:/code --network=none --memory=256MB --cpus 1 judge
