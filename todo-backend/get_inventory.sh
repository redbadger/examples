#!/bin/bash

HOSTS=$(wash ctl get hosts -o json | jq '.hosts[].id' | tr -d '"')

for HOST in $HOSTS; do
	wash ctl get inventory "$HOST" -o json | jq
done
