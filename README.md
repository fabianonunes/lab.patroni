# notas

As seguintes configurações são aplicadas apenas no bootstrap do cluster

```text
# controlled by Patroni
max_connections
max_locks_per_transaction
max_worker_processes
wal_keep_size
max_prepared_transactions
wal_level
track_commit_timestamp

# restricted to the dynamic configuration
max_wal_senders
max_replication_slots
wal_log_hints
```

Qualquer mudança posterio deve ser feita via `patronictl edit-config` ou `kubectl edit endpoint ${cluster_name}-config`

- No Django, em um failover, a conexão pode ficar em SYN-WAIT por tempo indeterminado até expirar o timeout.

## TODO

- exporter do pgbouncer
