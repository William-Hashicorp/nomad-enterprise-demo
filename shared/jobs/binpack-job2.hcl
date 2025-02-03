job "example-binpack2" {
# to ignore the node pool settings  
  node_pool = "all"
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