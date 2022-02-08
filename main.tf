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

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_ecs_cluster" "main" {
  name = "my-minecraft-server"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "my-minecraft-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  container_definitions = <<DEFINITION
[
  {
    "cpu":0,
    "dnsSearchDomains":[],
    "dnsServers":[],
    "dockerLabels":{},
    "dockerSecurityOptions":[],
    "essential":true,
    "extraHosts":[],
    "image": "nginx",
    "links":[],
    "mountPoints":[],
    "name": "testing",
    "portMappings":[
      {
        "containerPort": 80,
        "hostPort":80,
        "protocol": "tcp"
      }
    ],
    "ulimits":[],
    "volumesFrom":[],
    "environment": []
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "my-minecraft-server"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  force_new_deployment = true
  launch_type = "FARGATE"
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
  network_configuration {
    subnets = [ aws_subnet.main.id ]
    assign_public_ip = true
  }
}