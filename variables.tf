variable "region" {
  default = "us-east-2"
}

variable "aws-access-key" {
}

variable "aws-secret-key" {
}

variable "ec2-names" {
  type = list
  default = ["IS-Cluster-DR-a", "IS-Cluster-DR-b"]
}
