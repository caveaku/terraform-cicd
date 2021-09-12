provider "aws" {
    region = "us-east-1"
    access_key = "AKIAX53EWVBGF3ZCNAGN"
    secret_key = "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"

}

resource "aws_instance" "appserver" {
  ami = "ami-0d5eff06f840b45e9"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"

  tags = {
    Name = "appserver"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.sean.id
  instance_id = aws_instance.appserver.id
}

resource "aws_ebs_volume" "sean" {
  availability_zone = "us-east-1a"
  size              = 10
}

resource "aws_vpc" "appserverVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "appserverVPC"
  }
}

resource "aws_security_group" "appserverSG" {
  name        = "appserverSG"
  description = "Allow appserverSG inbound traffic"
  vpc_id      = aws_vpc.appserverVPC.id

  ingress {
    description      = "appserverSG from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "appserverSG from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "appserverSG"
  }
}

resource "aws_subnet" "pubsubnet" {
  vpc_id     = aws_vpc.appserverVPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pubsubner"
  }
}

resource "aws_subnet" "privsubnet" {
  vpc_id     = aws_vpc.appserverVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privsubner"
  }
}

resource "aws_internet_gateway" "appserverIGW" {
  vpc_id = aws_vpc.appserverVPC.id

  tags = {
    Name = "appserverIGW"
  }
}

resource "aws_route_table" "pubroutetable" {
  vpc_id = aws_vpc.appserverVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.appserverIGW.id
  }

  tags = {
    Name = "pubroutetable"
  }
}

resource "aws_route_table" "privroutetable" {
  vpc_id = aws_vpc.appserverVPC.id

  tags = {
    Name = "privroutetable"
  }
}

resource "aws_elb" "appserverELB" {
  name               = "appserverELB"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  tags = {
    Name = "appserverELB"
  }
}

