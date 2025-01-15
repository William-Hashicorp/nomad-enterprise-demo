job "hello-world" {
  # Define the multiregion deployment
  multiregion {
    # Deployment strategy
    strategy {
      max_parallel = 1
      on_failure   = "fail_local"
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

    # Constraint to ensure it runs only on Windows servers
    constraint {
      attribute = "${attr.kernel.name}"
      operator  = "="
      value     = "windows"
    }

    task "hello-world" {
      driver = "raw_exec"

      artifact {
        source      = "https://raw.githubusercontent.com/William-Hashicorp/nomad-enterprise-demo/refs/heads/main/shared/jobs/hello-world.ps1"
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