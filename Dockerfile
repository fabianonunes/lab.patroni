# syntax=docker/dockerfile:1

### go-builder
FROM golang:bookworm AS go-builder
RUN go install github.com/aptible/supercronic@v0.2.34
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3
RUN go install github.com/prometheus-community/postgres_exporter/cmd/postgres_exporter@v0.17.1

### metrics
FROM scratch AS metrics
COPY --from=go-builder /go/bin/postgres_exporter /usr/local/bin/
ENTRYPOINT [ "postgres_exporter" ]

### backup
FROM postgres:17.5-bookworm AS backup
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    curl \
    pgbackrest=2.56.0-1.pgdg120+1 \
    pid1 \
  ;
EOT
COPY --from=go-builder /go/bin/gomplate /usr/local/bin/
COPY fs.backup /
USER postgres
ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]

### patroni
FROM postgres:17.5-bookworm AS patroni
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    patroni=4.0.6-1.pgdg120+1 \
    pgbackrest=2.56.0-1.pgdg120+1 \
    pid1 \
  ;
EOT
COPY --from=go-builder /go/bin/gomplate /usr/local/bin/
COPY fs.patroni /
WORKDIR /etc/patroni
ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
