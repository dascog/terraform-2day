terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {
  host    = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "whoami" {
  name         = "sixeyed/whoami-dotnet:3.0"
  keep_locally = false
}

resource "docker_container" "whoami" {
  image = docker_image.whoami.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
