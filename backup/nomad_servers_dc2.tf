resource "aws_instance" "nomad_server_dc2" {
  count = 3
  ami           = var.ami
  instance_type = var.server_instance_type
  key_name      = aws_key_pair.nomad.key_name
  vpc_security_group_ids = [
    aws_security_group.consul_nomad_ui_ingress.id,
    aws_security_group.ssh_ingress.id,
    aws_security_group.allow_all_internal.id
  ]

  tags = merge(
    {
      "Name" = "${var.name_prefix}-nomad-server-dc2-${count.index}"
    },
    {
      "ConsulAutoJoin" = "auto-join"
    },
    {
      "NomadType" = "server"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/../shared/data-scripts/user-data-server.sh", {
    region      = var.region
    cloud_env   = "aws"
    datacenter  = "dc2"
    region_name = "region2"
    server_count = var.server_count
    retry_join  = var.retry_join
    nomad_binary = var.nomad_binary
    nomad_consul_token_id     = random_uuid.nomad_id.result
    nomad_consul_token_secret = random_uuid.nomad_token.result
  })

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}