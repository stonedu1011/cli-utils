#! /usr/bin/env bash
if (( EUID != 0 )); then
  echo "Please, run this command with sudo" 1>&2
  exit 1
fi
WIRELESS_INTERFACE=en0
TUNNEL_INTERFACE=utun1
GATEWAY=$(netstat -nrf inet | grep default | grep $WIRELESS_INTERFACE | awk '{print $2}')

echo "Resetting routes with gateway => $GATEWAY"
echo
# route -nv delete default -ifscope $WIRELESS_INTERFACE
route -nv delete -net default -interface $TUNNEL_INTERFACE
# route -nv add -net default $GATEWAY
for subnet in  10.86
do
  route -nv add -net $subnet -interface $TUNNEL_INTERFACE
done

# route -nv change default $GATEWAY