job "chat-app" {
  datacenters = ["dc1"]
  type = "service"
  node_pool = "all"
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }
  group "chat-app" {
    count = 3

    spread {
      attribute = "${node.unique.name}"
    }

    update {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "15s"
      healthy_deadline = "2m"
      canary = 1
    }

    network {
      mode = "bridge"
      port "http" {
        to = 5000
      }
    }

    task "chat-app" {
      driver = "exec"

      config {
        command = "chatapp-dark-linux"
      }

      artifact {
        source = "https://github.com/GuyBarros/anonymouse-realtime-chat-app/releases/download/0.04/chatapp-dark-linux"
        options {
          checksum = "md5:97fc2558be0f0585ea18ced1fc072185"
        }
      }

      env {
        MONGODB_SERVER = "127.0.0.1"
        MONGODB_PORT = "27017"
      }

      resources {
        cpu = 50 # MHz
        memory = 128 # MB
      }

    } # end chat-app task

    service {
      name = "chat-app"
      tags = ["chat-app"]
      port = "http"
      check {
        name     = "chat-app alive"
        type     = "http"
        path     = "/chats"
        interval = "10s"
        timeout  = "2s"
      }

      connect {
        sidecar_service {
          tags = ["chat-app-proxy"]
          proxy {
            upstreams {
              destination_name = "mongodb"
              local_bind_port = 27017
            }
          }
        }
      } # end connnect
    } # end service

  } # end chat-app group

}
