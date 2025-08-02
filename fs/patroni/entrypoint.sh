#!/bin/bash
set -e

gomplate --datasource postgresql.conf=postgresql.conf?type=application/x-env \
  --file patroni.yaml.tpl --out patroni.yaml

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD

chown postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

exec gosu postgres patroni patroni.yaml
