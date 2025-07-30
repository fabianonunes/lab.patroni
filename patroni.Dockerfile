# syntax=docker/dockerfile:1

### deps
FROM golang:bookworm AS deps
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3

### base
FROM postgres:17.5-bookworm AS base

RUN <<EOT
  set -e
  apt-get update
  apt-get install --yes --no-install-recommends \
    patroni=4.0.6-1.pgdg120+1 \
    pgbackrest=2.56.0-1.pgdg120+1 \
    pid1 \
  ;
  rm -rf /var/lib/apt/lists/* /etc/patroni/*
EOT

COPY --from=deps /go/bin/ /usr/local/bin/
COPY fs /

WORKDIR /etc/patroni

ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
