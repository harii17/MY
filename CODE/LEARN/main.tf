provider "aws" {
  region                  = "ap-south-1"
#  shared_credentials_file = "/home/hari/.aws/credentials"
  access_key = "AKIAYQGOCTWBWJQX6YF3"
  secret_key = "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"
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "terraform-igw"
  }
  
}

resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "terraform-pubsub" {
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "terraform-pubsub"
  }
}

resource "aws_subnet" "terraform-privsub" {
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "terraform-privsub"
  }
}

resource "aws_route_table" "terraform-pubrt" {
  vpc_id = aws_vpc.terraform-vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  } 

  tags = {
    Name = "terraform-pubrt"
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id = aws_subnet.terraform-pubsub.id
  route_table_id = aws_route_table.terraform-pubrt.id
}

resource "aws_eip" "terraform-eip" {
  instance = aws_instance.web.id
  vpc = true

  tags = {
    Name = "terraform-eip"
  }
}

resource "aws_security_group" "terraform-sg" {
  name = "terraform-sg"
  vpc_id = aws_vpc.terraform-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
#    cidr_blocks = [aws_subnet.terraform-pubsub.cidr_block]
    cidr_blocks = ["18.214.194.50/32"]    
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-sg"
  }
}



resource "aws_instance" "web" {
  ami           = "ami-08ee6644906ff4d6c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.terraform-pubsub.id
  key_name = "pub-sub-kp"
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  ebs_block_device {
    volume_size = 10
    device_name = "/dev/sda1"
  }

    tags = {
        Name = "terraform-instance-1"
    }
}

