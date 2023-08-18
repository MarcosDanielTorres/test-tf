terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
    host = "unix:///home/marcos/.docker/desktop/docker.sock"
}

variable "size" {
  type        = number
  description = "amount of web-servers to start"
  default     = 2
}


resource "docker_network" "skybox-ws-network" {
  name = "skybox-network"
}


resource "docker_image" "skybox-ws-nginx-image" {
  count = var.size
  name  = "skybox/ws-image-${count.index}"
  build {
    # dockerfile = ""
    # dockerfile = "${path.cwd}/build/web-servers/ws-${count.index + 1}/Dockerfile"
    # dockerfile = "Dockerfile"
    context = "${path.cwd}/build/web-servers/ws-${count.index + 1}/"
    
  }
  keep_locally = false
}

resource "docker_image" "skybox-lb-nginx-image" {
  name  = "skybox/lb-image"
  build {
    context = "${path.cwd}/build/load_balancer/"
  }
  keep_locally = false
}

resource "docker_container" "skybox-ws" {
  count = var.size
  depends_on   = [docker_network.skybox-ws-network, docker_image.skybox-ws-nginx-image]
  network_mode = "skybox-network"
  image        = docker_image.skybox-ws-nginx-image[count.index].image_id
  name         = "skybox-ws-${count.index + 1}"
  
  ports {
    internal = 80
    external = 8000 + count.index
  }
}


resource "docker_container" "skybox-lb" {
  depends_on   = [docker_network.skybox-ws-network]
  network_mode = "skybox-network"
  image        = docker_image.skybox-lb-nginx-image.image_id
  name         = "skybox-lb"
  
  ports {
    internal = 8080
    external = 8080
  }
}
