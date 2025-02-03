job "batch-job-test" {
  datacenters = ["dc1"]
  type        = "batch"
  # to ignore the node pool settings  
  node_pool = "all"

  group "example-group" {
    task "write-config-file" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/bash"
        args = [
          "-c",
          "cp secrets/run.env /tmp/config.txt && echo 'Configuration file copied to /tmp/config.txt' && cat /tmp/config.txt" 
        ]
      }

      template {
        data = <<EOH
export TEST_USER="{{ with nomadVar "nomad/jobs/batch-job-test" }}{{ .username }}{{ end }}"
export TEST_PASSWORD="{{ with nomadVar "nomad/jobs/batch-job-test" }}{{ .password }}{{ end }}"
EOH
        destination = "secrets/run.env"
        change_mode = "noop"
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}