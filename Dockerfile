# syntax=docker/dockerfile:1

### deps
FROM golang:bookworm AS deps
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3

### extensions
FROM debian:bookworm AS extensions
SHELL ["/bin/bash", "-ec"]

ARG VERSION=0.17.2

RUN <<EOT
  apt-get update
  apt-get install --yes wget

  package="postgresql-17-pg-search_${VERSION}-1PARADEDB-bookworm_amd64.deb"
  wget "https://github.com/paradedb/paradedb/releases/download/v${VERSION}/${package}"
  dpkg -x "${package}" /
EOT

### base
FROM postgres:17.5-bookworm
SHELL ["/bin/bash", "-ec"]

RUN <<EOT
  apt-get update
  apt-get install --yes --no-install-recommends \
    nano \
    patroni=4.0.6-1.pgdg120+1 \
    pid1 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

COPY --from=deps /go/bin/ /usr/local/bin/

COPY --from=extensions /usr/lib/postgresql/17/lib /usr/lib/postgresql/17/lib
COPY --from=extensions /usr/share/postgresql/17/extension /usr/share/postgresql/17/extension

COPY entrypoint.sh /entrypoint.sh
COPY patroni.yaml.tpl /etc/patroni/patroni.yaml.tpl

RUN chown postgres:postgres /etc/patroni
USER postgres
WORKDIR /etc/patroni

ENTRYPOINT [ "pid1", "--" ]
CMD [ "/entrypoint.sh" ]
