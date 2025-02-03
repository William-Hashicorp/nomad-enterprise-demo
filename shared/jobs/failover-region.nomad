job "hello-world" {
  region      = "global" # Enables cross-region scheduling
  datacenters = ["dc1", "dc2"] # Specifies eligible datacenters

  type        = "service"
  namespace   = "default"
  # to ignore the node pool settings  
  node_pool = "all"

  group "app-group" {
    count = 1

    # Affinity to prefer placement in 'dc1'
    affinity {
      attribute = "${node.datacenter}"
      operator  = "=="
      value     = "dc1"
      weight    = 90
    }

    affinity {
      attribute = "${node.datacenter}"
      operator  = "=="
      value     = "dc2"
      weight    = 10
    }

    # Ensure it runs only on Windows servers
    constraint {
      attribute = "${attr.kernel.name}"
      operator  = "=="
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