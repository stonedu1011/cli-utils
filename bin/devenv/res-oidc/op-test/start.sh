#!/usr/bin/env bash

SUBDIR="/usr/local/src/oidf/oidc_op"
INITDIR="${SUBDIR}/init"

# copy assigned_ports.json
current="`cat $SUBDIR/assigned_ports.json | tr -d '[:space:]'`"
if [ -z "$current" ]; then
  cp -p $INITDIR/assigned_ports.json $SUBDIR/
fi

# copy pre-defined configs if needed
cp -u -r -p $INITDIR/* $SUBDIR/

./run.sh