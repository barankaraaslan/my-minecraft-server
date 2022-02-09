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
  enable_dns_hostnames = true
  tags = {
    Name = "my-minecraft-server"
  }
}

resource "aws_security_group_rule" "in80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_vpc.main.default_security_group_id
  cidr_blocks = aws_vpc.main.cidr_block
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-minecraft-server"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "my-minecraft-server"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "my-minecraft-server"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
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
    security_groups = [ aws_vpc.main.default_security_group_id ]
    assign_public_ip = true
  }
}