job "catalogue" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 40
  namespace = "default"
  # to ignore the node pool settings  
  node_pool = "all"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    max_parallel = 1
  }


  # - catalogue - #
  group "catalogue" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
      port "db" {
        to = 3306
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "catalogue" {
      driver = "docker"

      config {
        image = "rberlind/catalogue:latest"
        command = "/app"
        args = ["-port", "8080", "-DSN", "catalogue_user:default_password@tcp(127.0.0.1:3306)/socksdb"]
        hostname = "catalogue.service.consul"
        network_mode = "host"
        ports = ["http"]
      }

      service {
        name = "catalogue"
        tags = ["app", "catalogue"]
        port = "http"
      }

      resources {
        cpu = 100 # Mhz
        memory = 128 # MB
      }
    } # - end app - #

    # - db - #
    task "cataloguedb" {
      driver = "docker"

      config {
        image = "rberlind/catalogue-db:latest"
        hostname = "catalogue-db.service.consul"
        command = "docker-entrypoint.sh"
        args = ["mysqld", "--bind-address", "127.0.0.1"]
        network_mode = "host"
        ports = ["db"]
      }

      env {
        MYSQL_DATABASE = "socksdb"
        MYSQL_ALLOW_EMPTY_PASSWORD = "true"
      }

      service {
        name = "catalogue-db"
        tags = ["db", "catalogue", "catalogue-db"]
        port = "db"
      }

      resources {
        cpu = 100 # Mhz
        memory = 256 # MB
      }

    } # - end db - #

  } # - end group - #
}
