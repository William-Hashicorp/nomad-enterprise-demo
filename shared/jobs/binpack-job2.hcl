job "example-binpack2" {
  #datacenters = ["dc1"]
  type = "service"

  group "example-group" {
    count = 1

    task "example-task" {
      driver = "docker"

      config {
        image = "nginx:latest"
      }

      resources {
        cpu    = 50
        memory = 25
      }
    }
  }
}