job "example-spread-1" {
  node_pool = "ubuntu-nodepool"
  type = "service"
  group "example-group" {
    count = 3
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