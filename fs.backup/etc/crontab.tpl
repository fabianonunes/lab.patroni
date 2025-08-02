{{ getenv "PATRONI_EXT_PGBACKREST_INCREMENTAL_SCHEDULE" "@daily" }} pgbackrest-backup
{{ getenv "PATRONI_EXT_PGBACKREST_FULL_SCHEDULE" "@weekly" }} pgbackrest-backup --type full
