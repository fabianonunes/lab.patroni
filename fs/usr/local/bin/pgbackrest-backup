#!/bin/bash

if curl --silent --fail http://localhost:8008/primary; then
  pgbackrest --stanza=main backup
fi
