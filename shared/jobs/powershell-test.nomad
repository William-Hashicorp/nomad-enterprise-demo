job "manage-windows-service" {
  datacenters = ["dc1"] # Replace with your datacenter
  type        = "service"

  group "windows-service-group" {
    count = 1

    # -----------------------------
    # 1. Lifecycle Hooks
    # -----------------------------
    lifecycle {
      # Prestart Hook: Install and Start the Service
      hook "prestart" {
        task "install-start-service" {
          driver = "raw_exec"

          config {
            command = "powershell.exe"
            args    = [
              "-NoProfile",
              "-ExecutionPolicy", "Bypass",
              "-Command",
              """
              # Check if the service exists
              if (-not (Get-Service -Name 'MyService' -ErrorAction SilentlyContinue)) {
                Write-Host 'Service MyService not found. Installing...'
                sc.exe create MyService binPath= 'C:\\path\\to\\MyService.exe' start= auto
              } else {
                Write-Host 'Service MyService already exists.'
              }

              # Start the service if not running
              $service = Get-Service -Name 'MyService' -ErrorAction SilentlyContinue
              if ($service.Status -ne 'Running') {
                Write-Host 'Starting service MyService...'
                Start-Service -Name 'MyService'
              } else {
                Write-Host 'Service MyService is already running.'
              }
              """
            ]
          }

          # Optional: Define a health check for the lifecycle task
          service {
            name = "install-start-service"
            port = "dummy" # Not used

            check {
              name     = "prestart-success"
              type     = "script"
              command  = "powershell.exe"
              args     = ["-Command", "exit 0"] # Always succeeds
              interval = "10s"
              timeout  = "5s"
            }
          }

          resources {
            network {
              port "dummy" {}
            }
          }

          # Restart policy for the lifecycle task
          restart {
            attempts = 1
            interval = "1m"
            delay    = "10s"
            mode     = "fail"
          }
        }
      }

      # Poststop Hook: Stop and Remove the Service
      hook "poststop" {
        task "stop-remove-service" {
          driver = "raw_exec"

          config {
            command = "powershell.exe"
            args    = [
              "-NoProfile",
              "-ExecutionPolicy", "Bypass",
              "-Command",
              """
              # Stop the service if running
              $service = Get-Service -Name 'MyService' -ErrorAction SilentlyContinue
              if ($service.Status -eq 'Running') {
                Write-Host 'Stopping service MyService...'
                Stop-Service -Name 'MyService' -Force
              } else {
                Write-Host 'Service MyService is not running.'
              }

              # Optionally remove the service
              if (Get-Service -Name 'MyService' -ErrorAction SilentlyContinue) {
                Write-Host 'Removing service MyService...'
                sc.exe delete MyService
              } else {
                Write-Host 'Service MyService does not exist.'
              }
              """
            ]
          }

          service {
            name = "stop-remove-service"
            port = "dummy" # Not used

            check {
              name     = "poststop-success"
              type     = "script"
              command  = "powershell.exe"
              args     = ["-Command", "exit 0"] # Always succeeds
              interval = "10s"
              timeout  = "5s"
            }
          }

          resources {
            network {
              port "dummy" {}
            }
          }

          restart {
            attempts = 1
            interval = "1m"
            delay    = "10s"
            mode     = "fail"
          }
        }
      }
    }

    # -----------------------------
    # 2. Main Monitoring Task
    # -----------------------------
    task "monitor-service" {
      driver = "raw_exec"

      config {
        command = "powershell.exe"
        args    = [
          "-NoProfile",
          "-ExecutionPolicy", "Bypass",
          "-File", "${NOMAD_TASK_DIR}\\monitor-service.ps1",
          "-ServiceName", "MyService",
          "-AlertEmail", "admin@example.com"
        ]
      }

      artifact {
        source      = "https://example.com/scripts/monitor-service.ps1" # Replace with your script URL
        destination = "${NOMAD_TASK_DIR}\\monitor-service.ps1"
      }

      # Define a health check to ensure the monitor script is running
      service {
        name = "monitor-windows-service"
        port = "dummy" # Not used

        check {
          name     = "monitor-alive"
          type     = "script"
          command  = "powershell.exe"
          args     = [
            "-Command",
            "exit 0" # Always succeeds; the main task is the monitor script
          ]
          interval = "30s"
          timeout  = "5s"
        }
      }

      resources {
        network {
          port "dummy" {}
        }
      }

      # Restart policy for the monitor task
      restart {
        attempts = 3
        interval = "5m"
        delay    = "10s"
        mode     = "fail"
      }
    }
  }
}