
BUF_IMG ?= buf

docker-buf:
	docker run  -v `pwd`:/mnt/pwd -w /mnt/pwd $(BUF_IMG) generate --template buf.gen.yaml --path proto

buf:
	docker run --rm -it  -v `pwd`:/mnt/pwd -w /mnt/pwd $(BUF_IMG) $(CMD)

bufe:
	docker run --rm -it --entrypoint /bin/sh -v `pwd`:/mnt/pwd -w /mnt/pwd $(BUF_IMG) $(CMD)

docker:
	docker build --tag $(BUF_IMG) --file Dockerfile .

# buf update dependencies
buf-build:
	buf mod update
	buf build

swagger-ui:
	 docker-compose -f docker-compose.yaml up
