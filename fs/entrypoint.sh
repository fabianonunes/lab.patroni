#!/bin/bash
set -e

gomplate --file patroni.yaml.tpl \
  --datasource postgresql.parameters=postgresql.parameters.yaml \
  --out patroni.yaml

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD

chown postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

exec pebble run --verbose "$@"
