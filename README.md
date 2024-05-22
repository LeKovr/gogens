# gogens
Docker image with a set of golang generators for protobuf-based projects

## Why (in russian)

Описание сервиса в .proto позволяет генерить и документацию и множество полезного кода. Используемые для этого генераторы развиваются
и регулярно обновляют версии. Когда генераторы ставятся локально и в команде есть несколько разработчиков, может возникнуть
ситуация, что у разных разработчиков установлены разные версии генераторов. И они генерят разный код (например, зашивая в 
него свою версию). В результате коммиты замусориваются (а могут и портиться) не связанными с .proto изменениями 
сгенерированного кода. Посчитав это проблемой, мы нашли 2 решения:
1. Добавить версии генераторов в зависимости проекта
2. Собрать генераторы в образ docker и всей командой его использовать

Проект gogens - вариант решения 2.

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

### buf.gen.yaml example

See [here](https://github.com/LeKovr/hocon/blob/main/buf.gen.yaml)

### Fetch buf.lock from gogens image

```
id=$$(docker create ghcr.io/apisite/gogens) ; \
docker cp $id:/app/buf.lock buf.lock ; \
docker rm -v $id
```


### Generate GRPC code

For ./proto/service.proto run command

```
docker run --rm  -v `pwd`:/mnt/pwd -w /mnt/pwd ghcr.io/apisite/gogens:latest generate --template buf.gen.yaml --path proto
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
docker run --rm  -v `pwd`:/mnt/pwd -w /mnt/pwd --entrypoint /go/bin/esbuild ghcr.io/apisite/gogens:latest  \
  zgen/ts/proto/service.pb.ts --bundle --outfile=/mnt/pwd/static/js/api.js --global-name=AppAPI
```

Result:

* static/js/api.js - service JS client for use in browser

## Thanks

* https://github.com/higebu/docker-protoc-go
* https://github.com/TheThingsIndustries/docker-protobuf
* https://github.com/eugene-bert/docker-buf
