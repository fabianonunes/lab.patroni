# syntax=docker/dockerfile:1

### deps
FROM golang:bookworm AS builder
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3

### base
FROM postgres:17.5-bookworm
RUN <<EOT
  set -e
  apt-get update
  apt-get install --yes --no-install-recommends \
    nano \
    patroni \
    pid1 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

COPY --from=builder /go/bin/ /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
COPY patroni.yaml.tpl /etc/patroni/patroni.yaml.tpl

RUN chown postgres:postgres /etc/patroni
RUN chmod 750 /var/lib/postgresql/data
USER postgres
WORKDIR /etc/patroni

ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
