output "lb_address_consul_nomad_dc2" {
  value = "http://${aws_instance.nomad_server_dc2[0].public_ip}"
}

output "consul_token_secret_dc2" {
  value = random_uuid.nomad_token.result
}

output "IP_Addresses_dc2" {
  value = <<EOF
Client public IPs (dc2): ${join(", ", aws_instance.nomad_client_dc2[*].public_ip)}
Server public IPs (dc2): ${join(", ", aws_instance.nomad_server_dc2[*].public_ip)}

The Consul UI can be accessed at http://${aws_instance.nomad_server_dc2[0].public_ip}:8500/ui
with the token: ${random_uuid.nomad_token.result}
EOF
}