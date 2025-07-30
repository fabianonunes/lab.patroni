# syntax=docker/dockerfile:1

ARG POSTGRESQL_VERSION=17.5-bookworm
ARG PATRONI_VERSION=4.0.6-1.pgdg120+1
ARG PGBACKREST_VERSION=2.56.0-1.pgdg120+1

### deps
FROM golang:bookworm AS deps
ARG CGO_ENABLED=0
RUN go install github.com/aptible/supercronic@v0.2.34
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3
RUN go install github.com/prometheus-community/postgres_exporter/cmd/postgres_exporter@v0.17.1

### metrics
FROM scratch AS metrics
COPY --from=deps /go/bin/postgres_exporter /
ENTRYPOINT [ "/postgres_exporter" ]

### backup
FROM postgres:${POSTGRESQL_VERSION} AS backup
ARG PGBACKREST_VERSION
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    curl \
    "pgbackrest=${PGBACKREST_VERSION}" \
    pid1 \
  ;
EOT
COPY --from=deps /go/bin/gomplate /go/bin/supercronic /usr/local/bin/
COPY fs.backup /
USER postgres
ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]

### patroni
FROM postgres:${POSTGRESQL_VERSION} AS patroni
ARG PATRONI_VERSION
ARG PGBACKREST_VERSION
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    "patroni=${PATRONI_VERSION}" \
    "pgbackrest=${PGBACKREST_VERSION}" \
    pid1 \
  ;
EOT
COPY --from=deps /go/bin/gomplate /usr/local/bin/
COPY fs.patroni /
WORKDIR /etc/patroni
ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
