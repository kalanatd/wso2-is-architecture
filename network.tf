resource "aws_vpc" "is-cluster-dr-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "IS-Cluster-DR-VPC"
  }
}

resource "aws_internet_gateway" "is-cluster-dr-vpc-gw" {
  vpc_id = aws_vpc.is-cluster-dr-vpc.id
  tags = {
    Name = "IS-Cluster-DR-IGW"
  }
}

#Public subnets

resource "aws_subnet" "is-cluster-dr-public-a" {
    vpc_id = aws_vpc.is-cluster-dr-vpc.id
    cidr_block = "10.10.10.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      Name = "IS-Cluster-DR-Public-Subnet-1"
    }
}

resource "aws_subnet" "is-cluster-dr-public-b" {
    vpc_id = aws_vpc.is-cluster-dr-vpc.id
    cidr_block = "10.10.20.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
      Name = "IS-Cluster-DR-Public-Subnet-2"
    }
}

#Private subnets

resource "aws_subnet" "is-cluster-dr-private-a" {
    vpc_id = aws_vpc.is-cluster-dr-vpc.id
    cidr_block = "10.10.1.0/24"
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      Name = "IS-Cluster-DR-Private-Subnet-1"
    }
}

resource "aws_subnet" "is-cluster-dr-private-b" {
    vpc_id = aws_vpc.is-cluster-dr-vpc.id
    cidr_block = "10.10.2.0/24"
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      Name = "IS-Cluster-DR-Private-Subnet-2"
    }
}
