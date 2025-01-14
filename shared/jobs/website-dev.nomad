job "website" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 40
  namespace = "dev"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    max_parallel = 1
  }

  group "nginx" {
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
    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:1.15.6"
        ports = ["http"]
      }

      service {
        name = "nginx-dev"
        tags = ["web", "nginx", "dev"]
        port = "http"
      }

      resources {
        cpu = 50 # Mhz
        memory = 64 # MB
      }
    } # - end task - #
  } # - end group - #

  group "mongodb" {
    count = 2

    network {
      port "db" {
        to = 27017
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - db - #
    task "mongodb" {
      driver = "docker"

      config {
        image = "mongo:3.4.3"
        ports = ["db"]
      }

      service {
        name = "mongodb-dev"
        tags = ["db", "mongodb", "dev"]
        port = "db"
      }

      resources {
        cpu = 50 # Mhz
        memory = 64 # MB
      }
    } # - end task - #
  } # - end group - #

}
