
# Docker image versions
ARG alpine=3.11
ARG go=1.14.0

# Package versions
ARG grpc=1.24.0
ARG gen_gogo=1.3.1
ARG gen_gateway=1.14.3
ARG gen_validator=0.3.0
ARG gen_wsdl=0.8.3
ARG gen_soap=0.4.5
ARG gen_doc=1.3.1

# Build all with golang image
FROM golang:${go}-alpine${alpine} AS builder

# Declare args used for build
ARG grpc
ARG gen_gogo
ARG gen_gateway
ARG gen_validator
ARG gen_wsdl
ARG gen_soap
ARG gen_doc

# Speed up build if proxy given
ARG GOPROXY
RUN echo $GOPROXY

RUN apk --update add git

WORKDIR /out/include

# nats-nrpc has no version yet
RUN go get -u github.com/nats-rpc/nrpc/protoc-gen-nrpc
# nrpc.proto used in .proto for nats options
RUN install -m 444 -D /go/src/github.com/nats-rpc/nrpc/nrpc.proto -t github.com/nats-rpc/nrpc

ENV GO111MODULE on

RUN go get -u google.golang.org/grpc@v${grpc}
RUN go get -u github.com/gogo/protobuf/protoc-gen-gogo@v${gen_gogo}
RUN go get -u github.com/gogo/protobuf/protoc-gen-gogofast@v${gen_gogo}
RUN install -m 444 -D $(find /go/pkg/mod/github.com/gogo/protobuf@v*/gogoproto/*.proto) -t github.com/gogo/protobuf/gogoproto
RUN install -m 444 -D $(find /go/pkg/mod/github.com/gogo/protobuf@v*/protobuf/google/protobuf/*.proto) -t github.com/gogo/protobuf/protobuf/google/protobuf

RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v${gen_gateway}
RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v${gen_gateway}
RUN install -m 444 -D $(find /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v*/third_party/googleapis/google/rpc -name '*.proto') -t google/rpc/
RUN install -m 444 -D $(find /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v*/third_party/googleapis/google/api -name '*.proto') -t google/api/
RUN install -m 444 -D $(find /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v*/protoc-gen-swagger/options -name '*.proto') -t protoc-gen-swagger/options

RUN go get -u github.com/mwitkow/go-proto-validators/protoc-gen-govalidators@v${gen_validator}
RUN install -m 444 -D $(find /go/pkg/mod/github.com/mwitkow/go-proto-validators@v* -name '*.proto') -t github.com/mwitkow/go-proto-validators

RUN go get -u github.com/UNO-SOFT/soap-proxy/protoc-gen-wsdl@v${gen_wsdl}
RUN go get -u github.com/UNO-SOFT/grpcer/protoc-gen-grpcer@v${gen_soap}

RUN go get -u github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v${gen_doc}

FROM alpine:$alpine

RUN apk --update --no-cache add protobuf libxml2-utils

COPY --from=builder /go/bin/protoc* /usr/local/bin/
COPY --from=builder /out/include /usr/local/include

ENTRYPOINT ["protoc", "-I/usr/local/include", "-I/usr/local/include/github.com/gogo/protobuf/protobuf"]
