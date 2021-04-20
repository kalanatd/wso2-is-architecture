terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

resource "aws_eip" "is-dr-bastion-eip" {
  vpc = true
  instance = aws_instance.is-dr-bastion.id
  depends_on = [aws_internet_gateway.is-cluster-dr-vpc-gw]
}

#Network Interface for EC2s
resource "aws_network_interface" "is-dr-cluster-node-private-ip-a" {
  subnet_id   = aws_subnet.is-cluster-dr-private-a.id
  private_ips = ["10.10.1.10"]

  tags = {
    Name = "primary_network_interface-a"
  }
}

resource "aws_network_interface" "is-dr-cluster-node-private-ip-b" {
  subnet_id   = aws_subnet.is-cluster-dr-private-b.id
  private_ips = ["10.10.2.10"]

  tags = {
    Name = "primary_network_interface-b"
  }
}

#ec2

resource "aws_instance" "is-dr-cluster-node-a" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c4.xlarge"
  network_interface {
    network_interface_id = aws_network_interface.is-dr-cluster-node-private-ip-a.id
    device_index         = 0
  }

  tags = {
    Name = var.ec2-names[0]
  }
}

resource "aws_instance" "is-dr-cluster-node-b" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c4.xlarge"
  network_interface {
    network_interface_id = aws_network_interface.is-dr-cluster-node-private-ip-b.id
    device_index         = 0
  }

  tags = {
    Name = var.ec2-names[1]
  }
}

resource "aws_instance" "is-dr-bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"


  tags = {
    Name = "IS-DR-Bastion"
  }
}

#loadbalancer_id

resource "aws_elb" "is-dr-cluster-elb" {
  name               = "is-dr-cluster-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  #security_group = aws_security_group.is-dr-elb-sg.id
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "IS-DR-ELB"
  }
}
