  job "high-prio-job" {
  priority = 80
  node_pool = "ubuntu-nodepool"
  type = "service"
  group "example-group" {
    count = 6
    task "example-task" {
      driver = "docker"
      config {
        image = "nginx:latest"
      }
      resources {
        cpu    = 50
        memory = 400
      }
      }
    }
  }