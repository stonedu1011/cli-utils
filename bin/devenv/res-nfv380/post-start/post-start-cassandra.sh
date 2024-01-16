#!/bin/sh

# Wait Cassandra to accept CQL
initial_delay=20s
timeout=120s
backoff=10s

echo "Waiting Cassandra to accept CQL..."
sleep $initial_delay
timeout $timeout sh << EOF || echo "Cassandra is not accepting CQL after $timeout seconds."
while ! cqlsh -k system -e "SELECT key,bootstrapped,cluster_name,cql_version,data_center FROM local" cassandra 9042 2>/dev/null; do
  echo "Retry CQL in $backoff..."
  sleep $backoff
done
EOF
