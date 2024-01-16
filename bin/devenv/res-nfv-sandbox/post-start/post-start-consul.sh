#!/bin/bash

export CONSUL_ADDR="http://consul-1:8500"

initial_delay=5s
timeout=20s
backoff=1s

# wait for consul to accept HTTP requests
sleep $initial_delay
timeout $timeout bash << EOF || echo "Consul is not accepting HTTP requests after $timeout seconds."
while ! curl -f -s -X GET $CONSUL_ADDR/v1/agent/services 2>&1 1>/dev/null; do
  echo "Retry in $backoff..."
  sleep $backoff
done
EOF

# try to deregister all services
services=(`curl -f -s -X GET $CONSUL_ADDR/v1/agent/services | jq -r '.[]["ID"]'`)
echo "Deregistering ${#services[@]} service instances ..."
for id in ${services[@]}; do
  consul services deregister -http-addr=$CONSUL_ADDR -id=$id
done
