job "mongodb" {
  datacenters = ["dc1"]
  type = "service"
   node_pool = "all"

  group "db" {
    count = 1

    volume "mongodb_vol" {
      type = "host"
      source = "mongodb_mount"
    }

    network {
      mode = "bridge"
    }

    task "mongodb" {
      driver = "docker"

      config {
        image = "mongo"
      }

      volume_mount {
        volume = "mongodb_vol"
        destination = "/data/db"
      }

      resources {
        cpu = 100 # MHz
        memory = 256 # MB
      }

    } # end mongodb task

    service {
      name = "mongodb"
      tags = ["mongodb"]
      port = "27017"

      connect {
        sidecar_service {}
      }
    } # end service

  } # end db group

}
