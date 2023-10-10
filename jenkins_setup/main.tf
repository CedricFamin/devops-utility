terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_network" "jenkins" {
  name = "jenkins"
}

resource "docker_image" "dind" {
  name = "docker:dind"
}

resource "docker_container" "dind" {
  name  = "jenkins-docker"
  image = docker_image.dind.image_id
  volumes {
    volume_name    = "jenkins-docker-certs"
    container_path = "/certs/client"
  }
  volumes {
    volume_name    = "jenkins-data"
    container_path = "/var/jenkins_home"
  }
  env        = ["DOCKER_TLS_CERTDIR=/certs"]
  rm         = true
  privileged = true
  networks_advanced {
    name    = docker_network.jenkins.name
    aliases = ["docker"]
  }
  ports {
    internal = 2376
    external = 2376
  }
}

resource "docker_image" "jenkins" {
  name = "myjenkins-blueocean:2.414.2-1"
}

resource "docker_container" "jenkins" {
  name  = "jenkins-blueocean"
  image = docker_image.jenkins.image_id
  networks_advanced {
    name = docker_network.jenkins.name
  }
  env = [
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1"
  ]
  volumes {
    volume_name    = "jenkins-docker-certs"
    container_path = "/certs/client"
    read_only      = true
  }
  volumes {
    volume_name    = "jenkins-data"
    container_path = "/var/jenkins_home"
  }

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }
}