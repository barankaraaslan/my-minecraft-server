terraform {
  required_providers {
    dockerhub = {
      source = "BarnabyShearer/dockerhub"
      version = "0.0.8"
    }
  }
}

provider "dockerhub" {
}

resource "dockerhub_repository" "main" {
  name = "my-minecraft-server"
  namespace = "barankaraaslan"
  description = "My minecraft server infrastructure"
  full_description = file("README.md")
}