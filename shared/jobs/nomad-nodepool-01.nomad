job "example-spread-1" {
  node_pool = "spread-nodepool"
  type = "service"
  group "example-group" {
    count = 8
    task "example-task" {
      driver = "docker"
      config {
        image = "nginx:latest"
      }
      resources {
        cpu    = 50
        memory = 26
      }
    }
  }
}