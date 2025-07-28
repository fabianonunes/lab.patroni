scope: batman
name: {{ getenv "HOSTNAME" }}

bootstrap:
  dcs:
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      pg_hba:
      - host all all 0.0.0.0/0 md5
      - host replication replicator 127.0.0.1/8 md5
      - host replication replicator {{ sockaddr.GetPrivateIP }}/16 md5
      parameters:
        max_connections: 150
        max_locks_per_transaction: 256
        max_worker_processes: 7
        wal_keep_size: 2GB

  initdb:
  - encoding: UTF8
  - data-checksums # necessário para pg_rewind

  basebackup:
  - verbose
  - max-rate: 100M

restapi:
  listen: "0.0.0.0:8008"
  connect_address: "{{ sockaddr.GetPrivateIP }}:8008"

postgresql:
  listen: "0.0.0.0:5432"
  connect_address: "{{ sockaddr.GetPrivateIP }}:5432"
  data_dir: /var/lib/postgresql/data
  pgpass: /tmp/pgpass0
  parameters:
{{ include "postgresql.parameters" | indent 4 }}

watchdog:
  mode: off
