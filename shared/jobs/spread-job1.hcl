job "example-spread1" {
  spread {
    attribute = "${node.datacenter}"
    weight    = 100

    target "dc1" {
      percent = 50
    }
    target "dc2" {
      percent = 50
    }
  }
  type = "service"

  group "example-group" {
    count = 1

    task "example-task" {
      driver = "docker"

      config {
        image = "nginx:latest"
      }

      resources {
        cpu    = 50 # 500 MHz
        memory = 25 # 256 MB
      }
    }
  }
}