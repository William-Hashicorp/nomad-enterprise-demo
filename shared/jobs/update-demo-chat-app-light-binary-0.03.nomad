job "chat-app" {
  datacenters = ["dc1"]  # Specifies the data center where the job will run
  type = "service"       # Declares the job type as a service
  node_pool = "all"      # Assigns the job to all available nodes in the cluster

  # Constraint to ensure the job only runs on Linux-based nodes
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "chat-app" {
    count = 3  # Deploys three instances of the group

    # Spreads the instances across unique nodes
    spread {
      attribute = "${node.unique.name}"
    }

    # Defines update strategy to ensure safe deployment
    update {
      max_parallel = 1       # Updates one instance at a time
      health_check = "checks" # Uses defined health checks for validation
      min_healthy_time = "15s" # Ensures an instance is healthy for at least 15 seconds before considering it stable
      healthy_deadline = "2m"  # Maximum time allowed for an instance to become healthy
    }

    # Defines network configuration
    network {
      mode = "bridge"  # Uses bridge networking mode
      port "http" {
        to = 5000  # Maps the container's port 5000 to an assigned dynamic port
      }
    }

    task "chat-app" {
      driver = "exec"  # Uses the 'exec' driver to run the application

      config {
        command = "chatapp-light-linux"  # Command to execute within the task
      }

      # Specifies an external artifact to download
      artifact {
        source = "https://github.com/GuyBarros/anonymouse-realtime-chat-app/releases/download/0.03/chatapp-light-linux"
        options {
          checksum = "md5:55677699984200530a836cf8fdec5bb5"  # Ensures the artifact integrity using MD5 checksum
        }
      }

      # Defines environment variables for the application
      env {
        MONGODB_SERVER = "127.0.0.1"  # Sets MongoDB server address
        MONGODB_PORT = "27017"        # Sets MongoDB server port
      }

      # Allocates resource limits for the task
      resources {
        cpu = 50   # Allocates 50 MHz of CPU
        memory = 128 # Allocates 128 MB of memory
      }

    } # end chat-app task

    # Registers the chat-app as a service
    service {
      name = "chat-app"  # Service name
      tags = ["chat-app"] # Tags for service discovery
      port = "http"  # Exposes the HTTP port

      # Defines a health check for the service
      check {
        name     = "chat-app alive"
        type     = "http"
        path     = "/chats"  # Health check endpoint
        interval = "10s"  # Runs every 10 seconds
        timeout  = "2s"   # Times out after 2 seconds if unresponsive
      }

      # Connects the service with Consul for service mesh features
      connect {
        sidecar_service {
          tags = ["chat-app-proxy"] # Tags for the proxy service
          proxy {
            upstreams {
              destination_name = "mongodb"  # Specifies the upstream service (MongoDB)
              local_bind_port = 27017       # Binds the local proxy port to MongoDB
            }
          }
        }
      } # end connect
    } # end service

  } # end chat-app group

} # end job