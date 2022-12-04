
GENS_IMG ?= gogens

gen:
	docker run  -v `pwd`:/mnt/pwd -w /mnt/pwd $(GENS_IMG) generate --template buf.gen.yaml --path proto

docker:
	docker build --tag $(GENS_IMG) .

# buf update dependencies
buf-build:
	buf mod update
	buf build
