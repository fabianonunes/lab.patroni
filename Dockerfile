# syntax=docker/dockerfile:1

ARG POSTGRESQL_IMAGE=postgres
ARG POSTGRESQL_VERSION=17.5-bookworm
ARG PATRONI_VERSION=4.0.6-1.pgdg120+1
ARG PGBACKREST_VERSION=2.56.0-1.pgdg120+1
ARG PGBOUNCER_VERSION=1.24.1-1.pgdg120+1

### deps
FROM golang:bookworm AS deps
ARG CGO_ENABLED=0
RUN go install github.com/aptible/supercronic@v0.2.34
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3
RUN go install github.com/prometheus-community/postgres_exporter/cmd/postgres_exporter@v0.17.1
RUN go install github.com/prometheus-community/pgbouncer_exporter@v0.11.0

### metrics
FROM scratch AS metrics
COPY --from=deps /go/bin/postgres_exporter /
ENTRYPOINT [ "/postgres_exporter" ]

### base
FROM ${POSTGRESQL_IMAGE}:${POSTGRESQL_VERSION} AS base
ARG PATRONI_VERSION
ARG PGBACKREST_VERSION
ARG PGBOUNCER_VERSION
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    curl \
    patroni="${PATRONI_VERSION}" \
    pgbackrest="${PGBACKREST_VERSION}" \
    pgbouncer="${PGBOUNCER_VERSION}" \
    pid1 \
  ;
EOT
COPY --from=deps /go/bin/gomplate /usr/local/bin/
ENTRYPOINT [ "pid1", "--" ]

### backup
FROM base AS backup
COPY --from=deps /go/bin/supercronic /usr/local/bin/
COPY fs.backup /
USER postgres
CMD [ "/entrypoint.sh" ]

### pgbouncer
FROM base AS pgbouncer
COPY --from=deps /go/bin/pgbouncer_exporter /usr/local/bin/
COPY fs.pgbouncer /
USER postgres
CMD [ "pgbouncer", "/etc/pgbouncer/pgbouncer.ini" ]

### patroni
FROM base AS patroni
RUN <<EOT
  set -ex
  apt-get update
  apt-get install --yes --no-install-recommends \
    postgresql-17-pgvector \
    postgresql-17-pgaudit \
  ;
EOT
COPY --from=extensions /usr/lib/postgresql/17/lib /usr/lib/postgresql/17/lib
COPY --from=extensions /usr/share/postgresql/17/extension /usr/share/postgresql/17/extension
COPY fs.patroni /
WORKDIR /etc/patroni
CMD [ "/entrypoint.sh" ]
