#IS cluster EC2 nodes
resource "aws_security_group" "is-dr-cluster-nodes-sg" {
  name        = "is-dr-cluster-nodes-sg"
  description = "Allow Bastion, RDS and ELB Traffic"
  vpc_id      = aws_vpc.is-cluster-dr-vpc.id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = aws_security_group.is-dr-bastion-sg.id
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = aws_security_group.is-dr-rds-sg.id
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = aws_security_group.is-dr-elb-sg.id
  }
  ingress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    security_groups = aws_security_group.is-dr-cluster-nodes-sg.id
  }
}

#Bastion Host SG
  resource "aws_security_group" "is-dr-bastion-sg" {
    name        = "is-dr-bastion-sg"
    description = "Allow IS Cluster Nodes"
    vpc_id      = aws_vpc.is-cluster-dr-vpc.id

    ingress {
      from_port = 22
      to_port = 22
      protocol = "ssh"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  #RDS Security group
  resource "aws_security_group" "is-dr-rds-sg" {
    name        = "is-dr-rds-sg"
    description = "Allow IS Cluster Nodes and Bastion SG"
    vpc_id      = aws_vpc.is-cluster-dr-vpc.id

    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = aws_security_group.is-dr-cluster-nodes-sg.id
    }
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = aws_security_group.is-dr-bastion-sg.id
    }
  }

  resource "aws_security_group" "is-dr-elb-sg" {
    name        = "is-dr-rds-sg"
    description = "Outside HTTP and HTTPS traffic"
    vpc_id      = aws_vpc.is-cluster-dr-vpc.id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "http"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 443
      to_port = 443
      protocol = "https"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
