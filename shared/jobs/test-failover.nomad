job "hello-world" {
  # Define the multi-region deployment
  multiregion {
    # Deployment strategy
    strategy {
      max_parallel = 1
      on_failure   = "fail_all"
    }

    # Primary region configuration
    region "region1" {
      count        = 1
      datacenters  = ["dc1"]
    }

    # Secondary region configuration for failover
    region "region2" {
      count        = 1
      datacenters  = ["dc2"]
    }
  }

  type      = "service"
  namespace = "default"

  group "app-group" {
    count = 1

    # Spread strategy to prioritize region1 and fallback to region2
    spread {
      attribute = "${node.datacenter}"
      weight = 100

      # Prefer region1 (dc1)
      target "dc1" {
        percent = 90
      }

      # Fallback to region2 (dc2)
      target "dc2" {
        percent = 10
      }
    }

    # Constraint to ensure it runs only on Windows servers
    constraint {
      attribute = "${attr.kernel.name}"
      operator  = "="
      value     = "windows"
    }

    task "hello-world" {
      driver = "raw_exec"

      artifact {
        source      = "https://raw.githubusercontent.com/William-Hashicorp/sampleapp/main/hello-world.ps1"
        destination = "${NOMAD_TASK_DIR}"
      }

      config {
        work_dir = "${NOMAD_TASK_DIR}"
        command  = "powershell.exe"
        args     = [
          "-File",
          "${NOMAD_TASK_DIR}\\hello-world.ps1"
        ]
      }

      resources {
        cpu    = 50  # CPU in MHz
        memory = 32  # Memory in MB
      }
    }
  }
}