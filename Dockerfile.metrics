# syntax=docker/dockerfile:1

### deps
FROM golang:bookworm AS deps
RUN go install github.com/prometheus-community/postgres_exporter/cmd/postgres_exporter@v0.17.1

### base
FROM postgres:17.5-bookworm AS base

COPY --from=deps /go/bin/ /usr/local/bin/

USER postgres
ENTRYPOINT [ "postgres_exporter" ]
