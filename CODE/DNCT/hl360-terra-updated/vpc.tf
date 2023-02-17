#VPC
resource "aws_vpc" "management" {
    cidr_block = "${var.mgmt_vpc_cidr}"
    enable_dns_hostnames = true
#    tags = {
#      "Name" = "Management"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-management" })
}

#Internet gateway
resource "aws_internet_gateway" "mgmt_igw" {
    vpc_id = aws_vpc.management.id

#    tags = {
#      "Name" = "igw"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-igw" })
}

#Public Subnet 1
resource "aws_subnet" "mgmt_pub_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pubsub1}"
    availability_zone = "${var.az_1}"
#    tags = {
#      "Name" = "mgmt-pub-sub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-pub-sub1" })
}

#Public Subnet 2
resource "aws_subnet" "mgmt_pub_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pubsub2}"
    availability_zone = "${var.az_2}"

#    tags = {
#      "Name" = "mgmt-pub-sub2"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-pub-sub2" })
}


#Private Subnet 1 in us-east-1a
resource "aws_subnet" "mgmt_pvt_sub1" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pvtsub1}"
    availability_zone = "${var.az_1}"

#    tags = {
#      "Name" = "mgmt-pvt-sub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-pvt-sub1" })
}

#Private Subnet 2 in us-east-1b
resource "aws_subnet" "mgmt_pvt_sub2" {
    vpc_id = aws_vpc.management.id
    cidr_block = "${var.mgmt_pvtsub2}"
    availability_zone = "${var.az_2}"

#    tags = {
#      "Name" = "mgmt-pvt-sub2"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-pvt-sub2" })
}

#Route table for public subnet1
resource "aws_route_table" "mgmt_rt_pubsub1" {
    vpc_id = aws_vpc.management.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.mgmt_igw.id
    } 
  
  #  tags = {
  #    "Name" = "mgmt-rt-pubsub1"
  #  }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-rt-pubsub1" })
}

#Route table association for public subnet1
resource "aws_route_table_association" "mgmt_rt_association_pubsub1" {
    subnet_id = aws_subnet.mgmt_pub_sub1.id
    route_table_id = aws_route_table.mgmt_rt_pubsub1.id
    depends_on = [
      aws_route_table.mgmt_rt_pubsub1
    ]
}


#Route table association for public subnet2
resource "aws_route_table_association" "mgmt_rt_association_pubsub2" {
    subnet_id = aws_subnet.mgmt_pub_sub2.id
    route_table_id = aws_route_table.mgmt_rt_pubsub1.id
    depends_on = [
      aws_route_table.mgmt_rt_pubsub1
    ]
}


#Route table for private subnet2
resource "aws_route_table" "mgmt_rt_pvtsub1" {
    vpc_id = aws_vpc.management.id
  
#    tags = {
#      "Name" = "mgmt-rt-pvtsub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-mgmt-rt-pvtsub1" })
}

#Route table association for private subnet2
resource "aws_route_table_association" "mgmt_rt_association_pvtsub2" {
    subnet_id = aws_subnet.mgmt_pvt_sub2.id
    route_table_id = aws_route_table.mgmt_rt_pvtsub1.id
    depends_on = [
      aws_route_table.mgmt_rt_pvtsub1
    ]
}

#Route table association for private subnet1
resource "aws_route_table_association" "mgmt_rt_association_pvtsub1" {
    subnet_id = aws_subnet.mgmt_pvt_sub1.id
    route_table_id = aws_route_table.mgmt_rt_pvtsub1.id
    depends_on = [
      aws_route_table.mgmt_rt_pvtsub1
    ]
}

######## FLOW LOG for Management VPC ###########

resource "aws_flow_log" "mgmt_flow_log" {
  iam_role_arn    = aws_iam_role.mgmt_iam_role.arn
  log_destination = aws_cloudwatch_log_group.mgmt_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.management.id
}

resource "aws_cloudwatch_log_group" "mgmt_log_group" {
  name = "management-vpc-flow-log"
  retention_in_days = "30"
}

resource "aws_iam_role" "mgmt_iam_role" {
  name = "flow-log-role-mgmt"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "mgmt_iam_policy" {
  name = "flow-log-policy-mgmt"
  role = aws_iam_role.mgmt_iam_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

### DEVELOPMENT VPC ###


#######
### PRODUCTION VPC ###

resource "aws_vpc" "production" {
  cidr_block = "${var.prod_vpc_cidr}"
  enable_dns_hostnames = true
#  tags = {
#      "Name" = "Production"
#    }

  tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-production" })
}

#Internet gateway
resource "aws_internet_gateway" "prod_igw" {
    vpc_id = aws_vpc.production.id

#    tags = {
#      "Name" = "igw-prod"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-igw-prod" })
}

#Public Subnet 1
resource "aws_subnet" "prod_pub_sub1" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pubsub1}"
    availability_zone = "${var.az_1}"

#    tags = {
#      "Name" = "prod-pub-sub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pub-sub1" })
}

#Public Subnet 2
resource "aws_subnet" "prod_pub_sub2" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pubsub2}"
    availability_zone = "${var.az_2}"

#    tags = {
#      "Name" = "prod-pub-sub2"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pub-sub2" })
}

#Route table for public subnet1
resource "aws_route_table" "prod_rt_pubsub1" {
    vpc_id = aws_vpc.production.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.prod_igw.id
    } 
  
#    tags = {
#      "Name" = "prod-rt-pubsub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-rt-pubsub1" })
}

#Route table association for public subnet1
resource "aws_route_table_association" "prod_rt_association_pubsub1" {
    subnet_id = aws_subnet.prod_pub_sub1.id
    route_table_id = aws_route_table.prod_rt_pubsub1.id
    depends_on = [
      aws_route_table.prod_rt_pubsub1
    ]
}


#Route table association for public subnet2
resource "aws_route_table_association" "prod_rt_association_pubsub2" {
    subnet_id = aws_subnet.prod_pub_sub2.id
    route_table_id = aws_route_table.prod_rt_pubsub1.id
    depends_on = [
      aws_route_table.prod_rt_pubsub1
    ]
}


#Elastic IP 1
resource "aws_eip" "eip1" {
    vpc = true
  
}

resource "aws_nat_gateway" "nat_pub_sub1" {
    subnet_id = aws_subnet.prod_pub_sub1.id
    allocation_id = aws_eip.eip1.id

#    tags = {
#      "Name" = "Nat-gw-pubsub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-natgw-pubsub1" })
}


resource "aws_subnet" "prod_pvt_sub1" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub1}"
    availability_zone = "${var.az_1}"

#    tags = {
#      "Name" = "prod-pvt-sub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pvt-sub1" })
}

resource "aws_subnet" "prod_pvt_sub2" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub2}"
    availability_zone = "${var.az_2}"

#    tags = {
#      "Name" = "prod-pvt-sub2"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pvt-sub2" })
}

#Route table for private subnet1
resource "aws_route_table" "prod_rt_pvtsub1" {
    vpc_id = aws_vpc.production.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_pub_sub1.id
    }
  
#    tags = {
#      "Name" = "prod-rt-pvtsub1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-rt-pvtsub1" })
}

#Route table association for private subnet1
resource "aws_route_table_association" "prod_rt_association_pvtsub1" {
    subnet_id = aws_subnet.prod_pvt_sub1.id
    route_table_id = aws_route_table.prod_rt_pvtsub1.id
    depends_on = [
      aws_route_table.prod_rt_pvtsub1
    ]
}

#Route table association for private subnet2
resource "aws_route_table_association" "prod_rt_association_pvtsub2" {
    subnet_id = aws_subnet.prod_pvt_sub2.id
    route_table_id = aws_route_table.prod_rt_pvtsub1.id
    depends_on = [
      aws_route_table.prod_rt_pvtsub1
    ]
}

resource "aws_subnet" "prod_pvt_sub_db1" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub_db1}"
    availability_zone = "${var.az_1}"

#    tags = {
#      "Name" = "prod-pvt-sub-db1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pvt-sub-db1" })
}

resource "aws_subnet" "prod_pvt_sub_db2" {
    vpc_id = aws_vpc.production.id
    cidr_block = "${var.prod_pvtsub_db2}"
    availability_zone = "${var.az_2}"

#    tags = {
#      "Name" = "prod-pvt-sub-db2"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-pvt-sub-db2" })
}

#Route table for private subnet db1
resource "aws_route_table" "prod_rt_pvtsub_db1" {
    vpc_id = aws_vpc.production.id
  
#    tags = {
#      "Name" = "prod-rt-pvtsub-db1"
#    }

    tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-prod-rt-pvtsub-db1" })
}

#Route table association for private subnet db1
resource "aws_route_table_association" "prod_rt_association_pvtsub_db1" {
    subnet_id = aws_subnet.prod_pvt_sub_db1.id
    route_table_id = aws_route_table.prod_rt_pvtsub_db1.id
    depends_on = [
      aws_route_table.prod_rt_pvtsub_db1
    ]
}

#Route table association for private subnet db2
resource "aws_route_table_association" "prod_rt_association_pvtsub_db2" {
    subnet_id = aws_subnet.prod_pvt_sub_db2.id
    route_table_id = aws_route_table.prod_rt_pvtsub_db1.id
    depends_on = [
      aws_route_table.prod_rt_pvtsub_db1
    ]
}

######## FLOW LOG for Production VPC ###########

resource "aws_flow_log" "prod_flow_log" {
  iam_role_arn    = aws_iam_role.prod_iam_role.arn
  log_destination = aws_cloudwatch_log_group.prod_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.production.id
}

resource "aws_cloudwatch_log_group" "prod_log_group" {
  name = "production-vpc-flow-log"
  retention_in_days = "30"
}

resource "aws_iam_role" "prod_iam_role" {
  name = "flow-log-role-prod"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "prod_iam_policy" {
  name = "flow-log-policy-prod"
  role = aws_iam_role.prod_iam_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


### VPC Peering ###

resource "aws_vpc_peering_connection" "peer1" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.management.id
  vpc_id        = aws_vpc.production.id
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-vpc-peer" })
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