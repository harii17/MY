#### MANAGEMENT VPC ####

resource "aws_vpc" "management" {
    cidr_block = "${var.mgmt_vpc_cidr}"
    tags = {
      "Name" = "Management"
    }
}

#Internet gateway
resource "aws_internet_gateway" "mgmt_igw" {
    vpc_id = aws_vpc.management.id

    tags = {
      "Name" = "igw"
    }
}

#Public Subnet 1
resource "aws_subnet" "mgmt_pub_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pubsub1}"
    availability_zone = "${var.az_1}"
    

    tags = {
      "Name" = "mgmt-pub-sub1"
    }
}

#Public Subnet 2
resource "aws_subnet" "mgmt_pub_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pubsub2}"
    availability_zone = "${var.az_2}"

    tags = {
      "Name" = "mgmt-pub-sub2"
    }
}


#Private Subnet 1 in us-east-1a
resource "aws_subnet" "mgmt_pvt_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pvtsub1}"
    availability_zone = "${var.az_1}"

    tags = {
      "Name" = "mgmt-pvt-sub1"
    }
}

#Private Subnet 2 in us-east-1b
resource "aws_subnet" "mgmt_pvt_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pvtsub2}"
    availability_zone = "${var.az_2}"

    tags = {
      "Name" = "mgmt-pvt-sub2"
    }
}

#Elastic IP 1
resource "aws_eip" "eip1" {
    vpc = true
  
}
#NAT gateway for public subnet1
resource "aws_nat_gateway" "nat_pub_sub1" {
    subnet_id = aws_subnet.mgmt_pub_sub1.id
    allocation_id = aws_eip.eip1.id

    tags = {
      "Name" = "Nat-gw-pubsub1"
    }
  
}

#Route table for public subnet1
resource "aws_route_table" "mgmt_rt_pubsub1" {
    vpc_id = aws_vpc.management.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.mgmt_igw.id
    } 
  
    tags = {
      "Name" = "mgmt-rt-pubsub1"
    }
}

#Route table association for public subnet1
resource "aws_route_table_association" "mgmt_rt_association_pubsub1" {
    subnet_id = aws_subnet.mgmt_pub_sub1.id
    route_table_id = aws_route_table.mgmt_rt_pubsub1.id
}


#Route table for public subnet2
resource "aws_route_table" "mgmt_rt_pubsub2" {
    vpc_id = aws_vpc.management.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.mgmt_igw.id
    } 
  
    tags = {
      "Name" = "mgmt-rt-pubsub2"
    }
}

#Route table association for public subnet2
resource "aws_route_table_association" "mgmt_rt_association_pubsub2" {
    subnet_id = aws_subnet.mgmt_pub_sub2.id
    route_table_id = aws_route_table.mgmt_rt_pubsub2.id
}

#Route table for private subnet1
resource "aws_route_table" "mgmt_rt_pvtsub1" {
    vpc_id = aws_vpc.management.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_pub_sub1.id
    }
  
    tags = {
      "Name" = "mgmt-rt-pvtsub1"
    }
}

#Route table association for private subnet1
resource "aws_route_table_association" "mgmt_rt_association_pvtsub1" {
    subnet_id = aws_subnet.mgmt_pvt_sub1.id
    route_table_id = aws_route_table.mgmt_rt_pvtsub1.id
}

#Elastic IP 2
resource "aws_eip" "eip2" {
    vpc = true
  
}
#NAT gateway for public subnet2
resource "aws_nat_gateway" "nat_pub_sub2" {
    subnet_id = aws_subnet.mgmt_pub_sub2.id
    allocation_id = aws_eip.eip2.id

    tags = {
      "Name" = "Nat-gw-pubsub2"
    }
  
}

#Route table for private subnet2
resource "aws_route_table" "mgmt_rt_pvtsub2" {
    vpc_id = aws_vpc.management.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_pub_sub2.id
    }
  
    tags = {
      "Name" = "mgmt-rt-pvtsub2"
    }
}

#Route table association for private subnet2
resource "aws_route_table_association" "rt-association-pvtsub2" {
    subnet_id = aws_subnet.mgmt_pvt_sub2.id
    route_table_id = aws_route_table.mgmt_rt_pvtsub2.id
}





### DEVELOPMENT VPC ###

resource "aws_vpc" "development" {
  cidr_block = "${var.dev_vpc_cidr}"
  tags = {
      "Name" = "Development"
    }
}

resource "aws_subnet" "dev_pvt_sub1" {
    vpc_id = aws_vpc.development.id
    cidr_block = "${var.dev_pvtsub1}"
    availability_zone = "${var.az_1}"

    tags = {
      "Name" = "dev-pvt-sub1"
    }
}

resource "aws_subnet" "dev_pvt_sub2" {
    vpc_id = aws_vpc.development.id
    cidr_block = "${var.dev_pvtsub2}"
    availability_zone = "${var.az_2}"

    tags = {
      "Name" = "dev-pvt-sub2"
    }
}

#Route table for private subnet1
resource "aws_route_table" "rt_pvtsub1" {
    vpc_id = aws_vpc.development.id
  
    tags = {
      "Name" = "dev-rt-pvtsub1"
    }
}

#Route table association for private subnet1
resource "aws_route_table_association" "rt_association_pvtsub1" {
    subnet_id = aws_subnet.dev_pvt_sub1.id
    route_table_id = aws_route_table.rt_pvtsub1.id
}

#Route table association for private subnet2
resource "aws_route_table_association" "dev_rt_association_pvtsub1" {
    subnet_id = aws_subnet.dev_pvt_sub2.id
    route_table_id = aws_route_table.rt_pvtsub1.id
}






#######
### PRODUCTION VPC ###

resource "aws_vpc" "production" {
  cidr_block = "${var.prod_vpc_cidr}"
  tags = {
      "Name" = "Production"
    }
}

resource "aws_subnet" "prod_pvt_sub1" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub1}"
    availability_zone = "${var.az_1}"

    tags = {
      "Name" = "prod-pvt-sub1"
    }
}

resource "aws_subnet" "prod_pvt_sub2" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub2}"
    availability_zone = "${var.az_2}"

    tags = {
      "Name" = "prod-pvt-sub2"
    }
}

#Route table for private subnet1
resource "aws_route_table" "prod_rt_pvtsub1" {
    vpc_id = aws_vpc.production.id
  
    tags = {
      "Name" = "prod-rt-pvtsub1"
    }
}

#Route table association for private subnet1
resource "aws_route_table_association" "prod_rt_association_pvtsub1" {
    subnet_id = aws_subnet.prod_pvt_sub1.id
    route_table_id = aws_route_table.prod_rt_pvtsub1.id
}

#Route table association for private subnet2
resource "aws_route_table_association" "prod_rt_association_pvtsub2" {
    subnet_id = aws_subnet.prod_pvt_sub2.id
    route_table_id = aws_route_table.prod_rt_pvtsub1.id
}





resource "aws_flow_log" "mgmt_flow_log_to_s3" {
#  iam_role_arn    = aws_iam_role.mgmt_iam_role.arn
#  log_destination = aws_s3_bucket.bucket_cloudwatch.arn
  log_destination = "${aws_s3_bucket.bucket_cloudwatch.arn}/management-vpc-flow-log"
  log_destination_type = "s3"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.management.id
  depends_on = [
    aws_vpc.management
  ]
}

resource "aws_flow_log" "dev_flow_log_to_s3" {
#  iam_role_arn    = aws_iam_role.dev_iam_role.arn
#  log_destination = aws_s3_bucket.bucket_cloudwatch.arn
  log_destination = "${aws_s3_bucket.bucket_cloudwatch.arn}/development-vpc-flow-log"
  log_destination_type = "s3"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.development.id
  depends_on = [
    aws_vpc.development
  ]
}

resource "aws_flow_log" "prod_flow_log_to_s3" {
#  iam_role_arn    = aws_iam_role.prod_iam_role.arn
#  log_destination = aws_s3_bucket.bucket_cloudwatch.arn
  log_destination = "${aws_s3_bucket.bucket_cloudwatch.arn}/production-vpc-flow-log"
  log_destination_type = "s3"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.production.id
  depends_on = [
    aws_vpc.production
  ]
}