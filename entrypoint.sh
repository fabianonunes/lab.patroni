#!/bin/bash
set -e

gomplate --file patroni.yaml.tpl \
  --datasource postgresql.parameters=postgresql.parameters.yaml \
  --out patroni.yaml

chown postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

exec gosu postgres patroni patroni.yaml
