group "sidecar" {
  # set the reschedule stanza so that we don't have to wait too long
  # for the deployment to be marked failed
  reschedule {
    attempts       = 1
    interval       = "24h"
    unlimited      = false
    delay          = "5s"
    delay_function = "constant"
  }

  task "sidecar" {
    driver = "docker"

    config {
      image   = "busybox:1"
      command = "/bin/sh"
      args    = ["local/script.sh"]
    }

    # this script will always fail in the east region
    template {
      destination = "local/script.sh"
      data        = <<EOT
if [[ ${NOMAD_REGION} == "region2" ]]
then
echo FAIL
exit 1
fi
echo OK
sleep 600

EOT

    }

    resources {
      cpu    = 128
      memory = 64
    }
  }
}
