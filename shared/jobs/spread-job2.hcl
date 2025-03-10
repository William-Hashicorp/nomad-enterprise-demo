job "example-spread2" {
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
  # to ignore the node pool settings  
  node_pool = "all"

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