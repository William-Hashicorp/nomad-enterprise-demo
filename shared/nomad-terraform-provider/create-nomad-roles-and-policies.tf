provider "nomad" {
    address = var.https_nomad_address
}

# Create ACL policies

resource "nomad_acl_policy" "dev-read" {
    name        = "dev-read"
    description = "Developer read policy"
    rules_hcl = <<EOT
namespace "default" {
  capabilities = [
    "list-jobs",
    "read-job"
  ]
}
EOT
}

resource "nomad_acl_policy" "dev-submit" {
    name        = "dev-submit"
    description = "Developer submit policy"
    rules_hcl = <<EOT
namespace "default" {
  capabilities = [
    "submit-job"
  ]
}
EOT
}

resource "nomad_acl_policy" "operator" {
    name        = "operator"
    description = "Operator policy"
    rules_hcl = <<EOT
node {
  policy = "read"
}

job {
  policy = "write"
}

agent {
  policy = "read"
}
EOT
}

resource "nomad_acl_policy" "admin" {
    name        = "admin"
    description = "Admin policy"
    rules_hcl = <<EOT
namespace "*" {
  policy = "write"
}

node {
  policy = "write"
}

agent {
  policy = "write"
}

operator {
  policy = "write"
}

quota {
  policy = "write"
}

plugin {
  policy = "write"
}

acl {
  policy = "write"
}

plugin {
  policy = "list"
}

system {
  policy = "write"
}
EOT
}

# Create ACL roles

resource "nomad_acl_role" "dev" {
  name        = "dev"
  description = "Developer role"

  policy {
    name = nomad_acl_policy.dev-read.name
  }

  policy {
    name = nomad_acl_policy.dev-submit.name
  }
}

resource "nomad_acl_role" "operator" {
  name        = "operator"
  description = "Operator role"

  policy {
    name = nomad_acl_policy.operator.name
  }
}

resource "nomad_acl_role" "admin" {
  name        = "admin"
  description = "Admin role"

  policy {
    name = nomad_acl_policy.admin.name
  }
}


# Create ACL tokens

resource "nomad_acl_token" "dev-token" {
  name      = "dev-token"
  type      = "client"
  role {
    id = nomad_acl_role.dev.id
  }
}

resource "nomad_acl_token" "operator-token" {
  name      = "operator-token"
  type      = "client"
  role {
    id = nomad_acl_role.operator.id
  }
}

resource "nomad_acl_token" "admin-token" {
  name      = "admin-token"
  type      = "client"
  role {
    id = nomad_acl_role.admin.id
  }
}