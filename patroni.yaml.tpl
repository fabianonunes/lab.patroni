scope: {{ getenv "PATRONI_SCOPE" "main" }}
name: {{ getenv "PATRONI_NAME" }}

restapi:
  listen: "0.0.0.0:8008"
  connect_address: "{{ sockaddr.GetPrivateIP }}:8008"

bootstrap:
  dcs:
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      pg_hba:
      - local all all trust
      - host all all 0.0.0.0/0 md5
      - host replication {{ getenv "PATRONI_REPLICATION_USERNAME" }} 127.0.0.1/8 md5
      - host replication {{ getenv "PATRONI_REPLICATION_USERNAME" }} {{ sockaddr.GetPrivateIP }}/16 md5
      parameters:
        ### controlled by Patroni
        max_connections:            {{ getenv "PATRONI_EXT_MAX_CONNECTIONS" }}
        max_locks_per_transaction:  {{ getenv "PATRONI_EXT_MAX_LOCKS_PER_TRANSACTION" }}
        max_worker_processes:       {{ getenv "PATRONI_EXT_MAX_WORKER_PROCESSES" }}
        wal_keep_size:              {{ getenv "PATRONI_EXT_WAL_KEEP_SIZE" }}
        max_prepared_transactions:  {{ getenv "PATRONI_EXT_MAX_PREPARED_TRANSACTIONS" }}
        wal_level:                  {{ getenv "PATRONI_EXT_WAL_LEVEL" }}
        track_commit_timestamp:     {{ getenv "PATRONI_EXT_TRACK_COMMIT_TIMESTAMP" }}

        ### restricted to the dynamic configuration
        max_wal_senders:            {{ getenv "PATRONI_EXT_MAX_WAL_SENDERS" }}
        max_replication_slots:      {{ getenv "PATRONI_EXT_MAX_REPLICATION_SLOTS" }}
        wal_log_hints:              {{ getenv "PATRONI_EXT_WAL_LOG_HINTS" }}

  method: pgbackrest
  pgbackrest:
    command: pgbackrest --stanza=main restore
    no_params: True
    recovery_conf:
      recovery_target_timeline: latest
      restore_command: pgbackrest --stanza=main archive-get %f %p

  initdb:
  - encoding: UTF8
  - data-checksums # necessário para pg_rewind

  basebackup:
  - verbose
  - max-rate: 100M

postgresql:
  listen: "0.0.0.0:5432"
  connect_address: "{{ sockaddr.GetPrivateIP }}:5432"
  data_dir: /var/lib/postgresql/data
  pgpass: /tmp/pgpass0
  authentication:
    superuser:
      password: {{ getenv "PATRONI_SUPERUSER_PASSWORD" }}
    replication:
      password: {{ getenv "PATRONI_REPLICATION_PASSWORD" }}

  create_replica_methods:
  - pgbackrest
  - basebackup
  pgbackrest:
    command: pgbackrest --stanza=main restore
    keep_data: True
    no_params: True
  basebackup:
  - verbose
  - checkpoint: fast
  - max-rate: 100M

  parameters:
    archive_mode: on
    archive_command: pgbackrest --stanza=main archive-push %p
{{ include "postgresql.parameters" | indent 4 }}

watchdog:
  mode: off
