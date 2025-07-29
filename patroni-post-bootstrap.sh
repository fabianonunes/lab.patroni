#!/bin/bash

if [[ ! -d /var/lib/pgbackrest/backup/main ]]; then
  pgbackrest --stanza=main stanza-create
  pgbackrest --stanza=main backup
fi
