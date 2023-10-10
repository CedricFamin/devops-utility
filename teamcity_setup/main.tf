terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_image" "teamcity_server" {
  name = "jetbrains/teamcity-server"
}

resource "docker_container" "teamcity_server" {
  name  = "teamcity-server-instance"
  image = docker_image.teamcity_server.image_id

  user = 0

  volumes {
    volume_name    = "teamcity_logs"
    container_path = "/opt/teamcity/logs"
  }
  volumes {
    volume_name    = "teamcity_data"
    container_path = "/data/teamcity_server/datadir"
  }

  ports {
    internal = 8111
    external = 8080
  }
}