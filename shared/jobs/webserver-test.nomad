job "webserver-test" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 40
  namespace = "qa"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    max_parallel = 1
  }

  group "webserver" {
    count = 2

    network {
      port "http" {
        to = 80
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - web - #
    task "webserver" {
      driver = "docker"

      config {
        # "httpd" is not an allowed image
        image = "httpd"
        ports = ["http"]
      }

      service {
        name = "webserver-test"
        tags = ["test", "webserver", "qa"]
        port = "http"
      }

      resources {
        cpu = 50 # Mhz
        memory = 64 # MB
      }
    } # - end task - #
  } # - end group - #
}
