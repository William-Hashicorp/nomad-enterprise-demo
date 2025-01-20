job "batch-job-test" {
  datacenters = ["dc1"]
  type        = "batch"

  group "example-group" {
    task "write-config-file" {
      driver = "exec"  # Use the exec driver to execute commands directly on the Nomad client

      config {
        command = "/bin/bash"
        args    = ["-c", "echo 'Configuration file created at /tmp/config.txt'"]
      }

      template {
        data = <<EOH
        TEST_USER="{{ with nomadVar "nomad/jobs/batch-job-test" }}{{ .username }}{{ end }}"
        EOH
        destination = "tmp/run.env"
        change_mode = "restart"   
      }


      resources {
        cpu    = 50  # Allocate minimal CPU
        memory = 32  # Allocate minimal memory
      }
    }
  }
}