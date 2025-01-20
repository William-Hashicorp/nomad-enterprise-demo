job "batch-job-test" {
  datacenters = ["dc1"] # The datacenter where this job will run
  type        = "service" # Define the job as a service to run continuously

  group "example-group" {
    task "write-config-file" {
      driver = "raw_exec" # Use the raw_exec driver to run commands directly on the host system

      config {
        command = "/usr/bin/bash" # Path to bash
        args = [
          "-c",
          "cp secrets/run.env /tmp/config.txt && echo 'Configuration file copied to /tmp/config.txt' && cat /tmp/config.txt && tail -f /dev/null"
        ]
      }

      template {
        # Render the environment file dynamically using nomadVar
        data = <<EOH
export TEST_USER="{{ with nomadVar "nomad/jobs/batch-job-test" }}{{ .username }}{{ end }}"
export TEST_PASSWORD="{{ with nomadVar "nomad/jobs/batch-job-test" }}{{ .password }}{{ end }}"
EOH
        destination = "secrets/run.env" # Write the rendered file to secrets/run.env
        env = true # Load variables into the task's environment
        change_mode = "restart" # Restart the task if the file changes
      }

      resources {
        cpu    = 50 # Minimal CPU allocation
        memory = 32 # Minimal memory allocation
      }
    }
  }
}