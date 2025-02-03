# Define a Nomad job named "hello_world"
job "hello_world" {

  # Specify the datacenter(s) where the job should run
  datacenters = ["dc1"]

  # Define the job type as "service" (used for long-running services)
  type = "service"

# to ignore the node pool settings  
  node_pool = "all"
  
  # Define a task group named "app"
  group "app" {

    # Specify the number of instances (allocations) for the task group
    count = 2

    # Configure network settings for the task group
    network {
      # Define a port label "http" and map it to container port 8000
      port "http" {
        to = 8000
      }
    }

    # Register the service for service discovery and health checks
    service {
      # Name of the service for service discovery
      name = "webapp"

      # Tags for integration with Traefik for routing
      tags = ["urlprefix-/", "traefik.enable=true", "traefik.http.routers.http.rule=Path(`/`)"]

      # Specify the port label to use for this service
      port = "http"

      # Define a health check for the service
      check {
        name     = "alive"      # Name of the health check
        type     = "http"       # Type of health check (HTTP)
        path     = "/"          # Endpoint to check
        interval = "10s"        # Frequency of health check
        timeout  = "2s"         # Timeout for health check responses
      }
    }

    # Define restart policy for failed tasks
    restart {
      attempts = 2      # Number of restart attempts before marking the task as failed
      interval = "30m"  # Time window for counting restart attempts
      delay = "15s"     # Delay before restarting the task
      mode = "fail"     # Restart mode: fail the task after max attempts
    }

    # Define a task named "server" within the task group
    task "server" {
      # Use the Docker driver to run the container
      driver = "docker"

      # Docker-specific configuration
      config {
        image = "mnomitch/hello_world_server"  # Docker image to use
        ports = ["http"]                      # Expose the port labeled "http"
      }

      # Define environment variables for the container
      env {
        MESSAGE = "Hello World!"  # Custom environment variable to display a message
      }
    }
  }
}