# dockerfile-protoc-go
Processing .proto for golang project via docker image

## Plugins

This image has protobuf package from alpine distributive and the following plugins:

* [grpc](https://google.golang.org/grpc)
* [gogo/protobuf](https://github.com/gogo/protobuf)
* [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway)
* [go-proto-validators](https://github.com/mwitkow/go-proto-validators)
* [nrpc](https://github.com/nats-rpc/)
* [soap-proxy](https://github.com/UNO-SOFT/soap-proxy)
* [grpcer](https://github.com/UNO-SOFT/grpcer)
* [proto docs](https://github.com/pseudomuto/protoc-gen-doc)

## Usage

For ./proto/messages.proto run command
```
docker run -ti --rm \
  -w $PWD \
  -v $PWD:$PWD \
  tenderpro/protoc-go -I=./proto \
    --gogofast_out=plugins=grpc:./proto/ \
    --grpc-gateway_out=logtostderr=true:./proto/ \
    --swagger_out=logtostderr=true:./assets/ \
    --grpcer_out=soap:soap \
    --wsdl_out=cmd/webserver/ \
    --nrpc_out=. \
    --doc_out=docs \
    --doc_opt=markdown,messages.md \
    messages.proto
```
which will generate:

* proto/messages.pb.go - gRPC service
* proto/messages.pb.gw.go - JSON service
* assets/messages.swagger.json - openapi definition
* soap/messages.grpcer.go - SOAP service
* cmd/webserver/messages.wsdl - WSDL file for SOAP service
* cmd/webserver/messages.wsdl.go - WSDL for SOAP service as golang variable
* messages.nrpc.go - NATS service (TODO: this file is obsolete and needs update)
* docs/messages.md - markdown docs for .proto, there are [several formats](https://github.com/pseudomuto/protoc-gen-doc#invoking-the-plugin) available

## Plans

The following plugins might be added in future:

* [protoc-gen-gotemplate](https://github.com/moul/protoc-gen-gotemplate)
* [envoyproxy/protoc-gen-validate](https://github.com/envoyproxy/protoc-gen-validate)
* [buf.build](https://buf.build/)

## Thanks

* https://github.com/higebu/docker-protoc-go
* https://github.com/TheThingsIndustries/docker-protobuf
