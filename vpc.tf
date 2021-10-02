resource "aws_vpc" "dove" {
  cidr_block           = var.vpc_CIDR
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = "true"
  tags = {
    Name = "dove"
  }
}

resource "aws_subnet" "dove-subnet-1" {
  vpc_id            = aws_vpc.dove.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dove-subnet-2" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "us-east-2a"
}
