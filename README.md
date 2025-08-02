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
- o healthcheck deveria conferir se a instância está muito atrasada
  - ideia para simular: troque as senhas de replicação e do superuser
    na secret e escreva uma quantidade grande de dados.
  - ou então investigar se tem alguma maneira de consultar no banco
    se a replicação está em dia ou bem configurada.
- backup full e incremental no cron
- usar `patroni --generate-sample-config` para ver ser tem alguma config importante
  - vale a pena passar o parâmetro `password_encryption: scram-sha-256` no postgresql.conf?
- quando usamos o restore com archive-get do pgbackrest significa que
  a replicação não depende mais do postgresql? ou seja, o wal em pg_wal
  não é mais necessário para a replicação?
