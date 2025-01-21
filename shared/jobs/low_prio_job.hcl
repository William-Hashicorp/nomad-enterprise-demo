    job "low-prio-job" {
      priority = 40
      node_pool = "ubuntu-nodepool"
      type = "service"
      group "example-group" {
        count = 2
        task "example-task" {
          driver = "docker"
          config {
            image = "nginx:latest"
          }
          resources {
            cpu    = 50 # 500 MHz
            memory = 300 # 256 MB
          }
        }
      }
    }