#Provider - AWS
provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}

#Management VPC
resource "aws_vpc" "management" {
    cidr_block = "10.0.0.0/16"
}

#Internet gateway in management VPC
resource "aws_internet_gateway" "mgmt_igw" {
    vpc_id = aws_vpc.management.id

    tags = {
      "Name" = "igw"
    }
}

#Management VPC Public Subnet 1 in us-east-1a
resource "aws_subnet" "mgmt_pub_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    

    tags = {
      "Name" = "mgmt_pub_sub1"
    }
}

#Management VPC Public Subnet 2 in us-east-1b
resource "aws_subnet" "mgmt_pub_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
      "Name" = "mgmt_pub_sub2"
    }
}

#Management VPC Private Subnet 1 in us-east-1a
resource "aws_subnet" "mgmt_pvt_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"

    tags = {
      "Name" = "mgmt_pvt_sub1"
    }
}

#Management VPC Private Subnet 2 in us-east-1b
resource "aws_subnet" "mgmt_pvt_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"

    tags = {
      "Name" = "mgmt_pvt_sub2"
    }
}


