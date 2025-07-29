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

## testes

<https://kagi.com/assistant/ceab7187-52c3-446d-a939-89162de2a07b>

num cluster patroni com 3 nodes, imagine que uma aplicação tenha aberto uma conexão com o master
(node0), que possui um IP virtual que é chaveado automaticamente por Service do tipo LoadBalancer.

depois de um tempo, o node1 se torna master (manualmente). o que acontece com aquela conexão aberta com o node0? ela vai ficar read only?

-- Permite conexões read-only no standby
SHOW hot_standby;
-- hot_standby | on
