nomad acl token list -json | jq -r '.[] | select(.Name == "dev-token" or .Name == "operator-token" or .Name == "admin-token") | .AccessorID' | while read -r accessor_id; do
    nomad acl token delete "$accessor_id"
done