# this script to cleanup all nomad tokens except the bootstrap token
nomad acl token list -json | jq -r '.[] | select(.Name != "Bootstrap Token") | .AccessorID' | while read -r accessor_id; do
nomad acl token delete "$accessor_id"
done