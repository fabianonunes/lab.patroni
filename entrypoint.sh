#!/bin/bash
set -e

gomplate --file patroni.yaml.tpl \
  --datasource postgresql.parameters=postgresql.parameters.yaml \
  --out patroni.yaml

exec patroni patroni.yaml
