#!/bin/bash -l

# This script will cleanup all nomad roles and policies 
set -euvo pipefail

echo "\
  ######################################################################
  START Clean Roles and Policies Script
  ######################################################################"

# Remove the roles
echo "Removing roles"
nomad acl role list -json | jq -r '.[].ID' | while read -r role_id; do
  nomad acl role delete "$role_id"
done
echo "Roles removed"

# Remove the policies
echo "Removing policies"
nomad acl policy list -json | jq -r '.[].Name' | while read -r policy_name; do
  nomad acl policy delete "$policy_name"
done
echo "Policies removed"

echo "\
  ######################################################################
  END Clean Roles and Policies Script
  ######################################################################"

exit 0