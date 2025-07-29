# syntax=docker/dockerfile:1

### deps
FROM golang:bookworm AS deps
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3
RUN go install github.com/aptible/supercronic@v0.2.34

### base
FROM postgres:17.5-bookworm AS base

RUN <<EOT
  set -e
  apt-get update
  apt-get install --yes --no-install-recommends \
    curl \
    pgbackrest=2.56.0-1.pgdg120+1 \
    pid1 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

COPY --from=deps /go/bin/ /usr/local/bin/

USER postgres
COPY fs.cron /
ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
