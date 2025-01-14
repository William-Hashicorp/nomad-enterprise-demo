#!/bin/bash

NOMAD_USER_TOKEN_FILENAME="nomad_dc2.token"
LB_ADDRESS=$(terraform output -raw lb_address_consul_nomad_dc2)
CONSUL_TOKEN=$(terraform output -raw consul_token_secret_dc2)

# Get nomad user token from consul kv
NOMAD_TOKEN=$(curl -s --header "Authorization: Bearer ${CONSUL_TOKEN}" "${LB_ADDRESS}:8500/v1/kv/nomad_user_token?raw")

if [ -n "$NOMAD_TOKEN" ]; then
  echo "$NOMAD_TOKEN" > "$NOMAD_USER_TOKEN_FILENAME"
else
  echo "Failed to retrieve Nomad user token from Consul"
  exit 1
fi