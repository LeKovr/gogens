

# Docker image versions
ARG go_ver=v1.18.5-alpine3.16.2
ARG buf_ver=1.7.0

# Docker images
ARG go_img=ghcr.io/dopos/golang-alpine

ARG gen_ver=v1.28.1
ARG gen_grpc_ver=v1.2.0
ARG gen_doc_ver=v1.5.1
ARG gen_gateway_ver=v2.11.3
ARG gen_gateway_ts_ver=v1.1.2
ARG gen_validate_ver=v0.6.7
ARG gowrap_ver=v1.2.7
ARG esbuild_ver=v0.15.9


FROM ${go_img}:${go_ver} as golang

ENV CGO_ENABLED=0 GO111MODULE=on

ARG gen_ver
ARG gen_grpc_ver
ARG gen_doc_ver
ARG gen_gateway_ver
ARG gen_gateway_ts_ver
ARG gen_validate_ver
ARG gowrap_ver
ARG esbuild_ver

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@${gen_ver}
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${gen_grpc_ver}
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@${gen_doc_ver}
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@${gen_gateway_ver}
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@${gen_gateway_ver}
RUN go install github.com/grpc-ecosystem/protoc-gen-grpc-gateway-ts@${gen_gateway_ts_ver}
RUN go install github.com/envoyproxy/protoc-gen-validate@${gen_validate_ver}

# non protoc generators

RUN go install github.com/hexdigest/gowrap/cmd/gowrap@${gowrap_ver}
RUN go install github.com/evanw/esbuild/cmd/esbuild@${esbuild_ver}

FROM bufbuild/buf:${buf_ver} as buf

ARG gen_gateway_ver

COPY --from=golang /go/bin /go/bin
RUN ls -l /go/bin

WORKDIR /app
# sample .proto for buf mod update
COPY --from=golang /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway/v2@${gen_gateway_ver}/examples/internal/proto/examplepb/echo_service.proto ./proto/service.proto

#RUN apk add --no-cache libstdc++

# Prepare buf cache

COPY buf.* ./
RUN buf mod update
COPY template.tmpl .
COPY proto.config.swagger.yaml .

ENV PATH="/go/bin:${PATH}"
RUN buf --debug generate --template buf.gen.yaml --path proto

ENTRYPOINT ["/usr/local/bin/buf"]
