#!/bin/sh

# Wait CP-Control-Center to accept connection
initial_delay=20
timeout=120
backoff=5

echo "Waiting CP Control Center to accept HTTP connection..."
sleep $initial_delay
timeout -t $timeout sh << EOF || echo "CP Control Center is not accepting HTTP connections after $timeout seconds."
while ! curl http://cpcc:9021 2>/dev/null; do
  echo "Retry http://cpcc:9021 in $backoff..."
  sleep $backoff
done
EOF
