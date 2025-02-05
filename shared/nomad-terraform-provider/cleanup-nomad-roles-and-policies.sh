#!/bin/bash -l

# This script will cleanup specific Nomad roles and policies
set -euvo pipefail

echo "\
  ######################################################################
  START Clean Roles and Policies Script
  ######################################################################"

# Remove the specified roles
echo "Removing specific roles: dev, operator, admin"
nomad acl role list -json | jq -r '.[] | select(.Name == "dev" or .Name == "operator" or .Name == "admin") | .ID' | while read -r role_id; do
  nomad acl role delete "$role_id"
done
echo "Specified roles removed"

# Remove the specified policies
echo "Removing specific policies: admin, operator, dev-submit, dev-read"
nomad acl policy list -json | jq -r '.[] | select(.Name == "admin" or .Name == "operator" or .Name == "dev-submit" or .Name == "dev-read") | .Name' | while read -r policy_name; do
  nomad acl policy delete "$policy_name"
done
echo "Specified policies removed"

echo "\
  ######################################################################
  END Clean Roles and Policies Script
  ######################################################################"

exit 0