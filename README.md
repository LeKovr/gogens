# gogens
Set of golang generators for GRPC projects

## Generators

### Packages used via [buf.build](https://buf.build/)

* [protobuf](https://google.golang.org/protobuf)
* [google grpc](https://google.golang.org/grpc)
* [protoc-gen-doc](https://github.com/pseudomuto/protoc-gen-doc)
* protoc-gen-grpc-gateway and protoc-gen-openapiv2 from [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway)


* [protoc-gen-grpc-gateway-ts](https://github.com/grpc-ecosystem/protoc-gen-grpc-gateway-ts)
* [protoc-gen-validate](https://github.com/envoyproxy/protoc-gen-validate)

### non protoc generators

* [gowrap](https://github.com/hexdigest/gowrap)
* [esbuild](https://github.com/evanw/esbuild)

## Usage

### Generate GRPC code

For ./proto/service.proto run command

```
docker run --rm  -v `pwd`:/mnt/pwd -w /mnt/pwd gogens generate --template buf.gen.yaml --path proto
```
Result:

* proto/README.md - markdown docs for .proto
* zgen/go/proto - golang code
** service_grpc.pb.go - gRPC service
** service.pb.go
** service.pb.gw.go - JSON service
** service.pb.validate.go - API validator
* zgen/ts - typescript code
** proto/service.pb.ts - TS client
** fetch.pb.ts - fetch lib

### Generate JS client

For generated zgen/ts files run

```
docker run --rm  -v `pwd`:/mnt/pwd -w /mnt/pwd gogens --entrypoint /opt/go/esbuild \
 service.pb.ts --bundle \
 --outfile=/mnt/pwd/static/js/api.js --global-name=AppAPI
```

Result:

* static/js/api.js - service JS client for use in browser

## Thanks

* https://github.com/higebu/docker-protoc-go
* https://github.com/TheThingsIndustries/docker-protobuf
* https://github.com/eugene-bert/docker-buf
