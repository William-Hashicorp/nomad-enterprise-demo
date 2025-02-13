job "mock-app" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "all"
  
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "mock-app" {
    # disable deployments
    update {
      max_parallel = 0
    }

    task "await-mock-service" {
      driver = "docker"

      config {
        image        = "busybox:1.28"
        command      = "sh"
        args         = ["-c", "echo -n 'Waiting for service'; until nslookup mock-service.service.consul 2>&1 >/dev/null; do echo '.'; sleep 2; done"]
        network_mode = "host"
      }

      resources {
        cpu    = 200
        memory = 128
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "mock-app-container" {
      driver = "docker"

      config {
        image   = "busybox"
        command = "sh"
        args    = ["-c", "echo The app is running! && sleep 3600"]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
