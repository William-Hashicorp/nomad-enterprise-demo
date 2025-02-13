job "mock-service" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "all"
  
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }
  
  group "mock-service" {
    task "mock-service" {
      driver = "docker"

      config {
        image   = "busybox"
        command = "sh"
        args    = ["-c", "echo The service is running! && while true; do sleep 2; done"]
      }

      resources {
        cpu    = 200
        memory = 128
      }

      service {
        name = "mock-service"
      }
    }
  }
}

