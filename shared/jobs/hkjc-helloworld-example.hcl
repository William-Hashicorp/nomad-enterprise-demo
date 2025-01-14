job "helloworld-net-service" {
  datacenters = ["st"]
  namespace = "default"

  constraint {
    attribute = "${node.unique.name}"
    operator = "regexp"
    value     = "WINNETCORETEST0"
  }

  group "dotnet" {
    count = 1

    network {
      port "health_port" { static = 8081 }
    }

    service {
      provider = "nomad"
      name     = "helloworld-http"
      check {
        name     = "readiness_probe"
        type     = "http"
        port     = "health_port"
        path     = "/api/healthcheck"
        interval = "3s"
        timeout  = "2s"

        check_restart {
            limit = 3
            grace = "10s"
            ignore_warnings = false
        }
      }
    }


    task "install-window-service" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      artifact {
        source      = "https://<the artifactory host>/artifactory/itswscd-snapshot-local/org/hkjc/ciws/helloworld-net/helloworld-net-0.0.0.198.zip"
        destination = "local\\helloworld-net-0.0.0.198"
      }

      template {
        destination = "local\\helloworld-net-0.0.0.198\\config.properties"
        data =<<EOF
        ADDR={{ env "NOMAD_ADDR_health_port" }}
        IP={{ env "NOMAD_IP_health_port" }}
        PORT={{ env "NOMAD_PORT_health_port" }}
        EOF
      }

      driver = "raw_exec"
      config {
        work_dir = "${NOMAD_TASK_DIR}\\helloworld-net-0.0.0.198"
        command = "powershell.exe"
        args = ["New-Service -Name ${NOMAD_JOB_NAME}-${NOMAD_SHORT_ALLOC_ID} -DisplayName ${NOMAD_JOB_NAME} -BinaryPathName ${NOMAD_TASK_DIR}\\helloworld-net-0.0.0.198\\Helloworld.exe -Description ${NOMAD_JOB_NAME} -StartupType Manual"]
      }
    }

    task "dotnet-svc" {
      driver = "raw_exec"
      
      template {
        destination = "local\\run-win-service.ps1"
        data=<<EOF
          # Define the name of the Windows service
          $serviceName = "{{ env "NOMAD_JOB_NAME" }}-{{ env "NOMAD_SHORT_ALLOC_ID" }}"  

          # Function to check the service status
          function Get-ServiceStatus {
              param (
                  [string]$name
              )
              $service = Get-Service -Name $name -ErrorAction SilentlyContinue
              return $service.Status
          }

          # Start the service if it is not running
          $serviceStatus = Get-ServiceStatus -name $serviceName
          if ($serviceStatus -ne 'Running') {
              Write-Host "Starting service '$serviceName'..."
              Start-Service -Name $serviceName
              # Wait for a moment to allow the service to start
              Start-Sleep -Seconds 30
          }

          # Loop to check the service status
          while ($true) {
              $serviceStatus = Get-ServiceStatus -name $serviceName
              Write-Host "Current status of '$serviceName': $serviceStatus"
              
              if ($serviceStatus -eq 'Stopped') {
                  Write-Host "Service '$serviceName' has stopped. Exiting script."
                  break
              }
              
              # Wait for a few seconds before checking again
              Start-Sleep -Seconds 2
          }
        EOF
      }

      config {
        work_dir = "${NOMAD_TASK_DIR}"
        command = "powershell.exe"
        args = ["${NOMAD_TASK_DIR}\\run-win-service.ps1"]
      }
    }
    
    
    task "remove-window-service" {
      lifecycle {
        hook = "poststop"
      }

      driver = "raw_exec"
      config {
        command = "sc.exe"
        args = ["delete", "${NOMAD_JOB_NAME}-${NOMAD_SHORT_ALLOC_ID}"]
      }
    }


  }
}