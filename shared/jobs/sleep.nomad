job "sleep" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 40
  namespace = "default"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }
  
  task "sleep" {
    driver = "exec"

    config {
      command = "/bin/sleep"
      args    = ["60"]
    }
  }
}
