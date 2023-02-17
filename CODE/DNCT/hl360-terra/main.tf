#Provider - AWS
data "aws_caller_identity" "current" {}

#### MANAGEMENT VPC ####
#VPC
resource "aws_vpc" "management" {
    cidr_block = "${var.mgmt_vpc_cidr}"
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


### Security Group ##

resource "aws_security_group" "alb_sg" {
  name        = "${lookup(var.common_tags, "Stack")}-alb-sg"
  description = "Allow traffice to webservers"
  vpc_id      = aws_vpc.production.id

  ingress {
    description = "HTTPS to outer world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP local"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.prod_vpc_cidr]
  }
  ingress {
    description = "HTTP to outer world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-alb-sg" })
}

resource "aws_security_group" "database-security-group" {
  name        = "${lookup(var.common_tags, "Stack")}-db-sg"
  description = "Allow traffic to RDS"
  #vpc_id      = aws_vpc.vpc.id
  vpc_id      = aws_vpc.production.id

  ingress {
    description = "Mariadb ACCESS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.production
  ]
}

## DB ##

# terraform aws db subnet group
resource "aws_db_subnet_group" "database-subnet-group" {
  name         = "database subnets2"
  subnet_ids   = [aws_subnet.prod_pvt_sub_db1.id, aws_subnet.prod_pvt_sub_db2.id]
  description  = "Subnets for Database Instance"

  tags   = {
    Name = "Database Subnets"
  }
}



resource "aws_db_instance" "database-instance" {
  instance_class          = "${var.database-instance-class}"
  allocated_storage       = "${var.allocated_storage}"
  engine                  = "mariadb"
  engine_version          = "10.6"
  skip_final_snapshot     = true
#  availability_zone       = [${var.az_1}, ${var.az_2}]
  identifier              = "${var.database-instance-identifier}"
  username                = "${var.dbusername}"
  password                = "${var.dbpass}"
  db_subnet_group_name    = aws_db_subnet_group.database-subnet-group.name
  multi_az                = "${var.multi-az-deployment}"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  storage_encrypted       = true
  deletion_protection     = true
  vpc_security_group_ids  = [aws_security_group.database-security-group.id]
}



###########
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}
########

## Target Group ##

resource "aws_lb_target_group" "target-group-web" {
  name        = "${lookup(var.common_tags, "Stack")}-tgt-gp-web"
#  name        = "test-tgt-gp-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.production.id
  target_type = "instance"
#  count       = lookup(var.web_server, "active") == "true" ? 1 : 0
  health_check {
    healthy_threshold   = 2
    interval            = 150
    path                = "/"
    timeout             = 3
    unhealthy_threshold = 8
    port                = 80
    #"${var.health_check_port}"
  }
  tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-tgt-gp-web" })
}

#resource "aws_lb_target_group_attachment" "test" {
#  target_group_arn = aws_lb_target_group.target-group-web.arn
#  target_id        = data.aws_instance.web.id
#  port             = 80
#}

#data "aws_instance" "web" {
#  filter {
#  name = "image-id"
#  values = [lookup(var.web-type, "ami")]
#  }
#}

## ALB ##

resource "aws_lb" "public_alb" {
  name                       = "${lookup(var.common_tags, "Stack")}-pub-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.prod_pub_sub1.id, aws_subnet.prod_pub_sub2.id]
  idle_timeout               = "400"
  enable_deletion_protection = true
  access_logs {
    bucket  = aws_s3_bucket.alb_bucket.id
    prefix  = var.alb_log_prefix
    enabled = "true"
  }
  depends_on = [
    aws_security_group.alb_sg,
  ]
  #"${var.alb_idle_timeout}"
#  tags = merge(var.common_tags, { Role = "load_balancer" })
}

# Below rule for testing
resource "aws_lb_listener" "test_listner" {
  load_balancer_arn = "${aws_lb.public_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target-group-web.arn
  }
}
#

#resource "aws_lb_listener" "listener_80" {
#  load_balancer_arn = "${aws_lb.public_alb.arn}"
#  port              = "80"
#  protocol          = "HTTP"

#  default_action {
#    type = "redirect"

#    redirect {
#      port        = "443"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}


#Note:- alb listner rule and target group attachment is pending to add


## Autoscaling ##

resource "aws_launch_configuration" "lc_web" {
  name_prefix          = "${lookup(var.common_tags, "Stack")}-web-lc-"
  image_id             = lookup(var.web-type, "ami")
  instance_type        = lookup(var.web-type, "type")
  ebs_optimized        = true
  security_groups      = [aws_security_group.alb_sg.id]
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  key_name             = "myKey"
  user_data            = <<-EOF
                          #!/bin/bash
                          sudo apt update && sudo apt install nginx -y
                          EOF
#  count                = lookup(var.web_server, "active") == "true" ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_security_group.alb_sg,
  ]
}

resource "aws_autoscaling_group" "web-asg" {
  name                      = "${lookup(var.common_tags, "Stack")}-web-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 600
  default_cooldown          = 300
  termination_policies      = ["NewestInstance"]
  vpc_zone_identifier       = [var.prod_pvtsub1, var.prod_pvtsub2]
  enabled_metrics           = ["GroupTerminatingInstances", "GroupMaxSize", "GroupDesiredCapacity", "GroupPendingInstances", "GroupInServiceInstances", "GroupMinSize", "GroupTotalInstances", "GroupStandbyInstances"]
  metrics_granularity       = "1Minute"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc_web.name
#  count                     = lookup(var.web_server, "active") == "true" ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }
#  tags = concat(var.extra_tags, var.extra_tags_web)

}

#####
#Autoscaling policies
resource "aws_autoscaling_policy" "web_scaleup_policy" {
#  count                  = lookup(var.web_server, "active") == "true" ? 1 : 0
  name                   = "${lookup(var.common_tags, "Stack")}-web-asg-scalingup"
  cooldown               = 600
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}
resource "aws_autoscaling_policy" "web_scaledown_policy" {
#  count                  = lookup(var.web_server, "active") == "true" ? 1 : 0
  name                   = "${lookup(var.common_tags, "Stack")}-web-asg-scalingdown"
  cooldown               = 600
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

resource "aws_autoscaling_attachment" "asg_attachment_web" {
#  count                  = lookup(var.web_server, "active") == "true" ? 1 : 0
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.id}"
  lb_target_group_arn   = "${aws_lb.public_alb.arn}"
}


#######
resource "aws_cloudwatch_metric_alarm" "web_cpuutilization_high" {
#  count               = lookup(var.web_server, "active") == "true" ? 1 : 0
  alarm_name          = "${lookup(var.common_tags, "Stack")}_web_cpuutilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "1800"
  statistic           = "Average"
  threshold           = "90"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
  }
  alarm_description = "This metric monitors Network packets in becomes > 50000 bytes"
  alarm_actions     = ["${aws_autoscaling_policy.web_scaleup_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "web_cpuutilization_low" {
#  count               = lookup(var.web_server, "active") == "true" ? 1 : 0
  alarm_name          = "${lookup(var.common_tags, "Stack")}_web_cpuutilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "1800"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
  }
  alarm_description = "This metric monitors ec2 Network packets in becomes < 10000 bytes"
  alarm_actions     = ["${aws_autoscaling_policy.web_scaledown_policy.arn}"]
}

########

## SNS Topic ##

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
  fifo_topic = false
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "harikrishnan.v@dinoct.com"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_updates.arn
  
#  policy = data.aws_iam_policy_document.sns_topic_policy.json
  policy = templatefile("./sns_topic_policy.json", {})
  depends_on = [
    aws_sns_topic.user_updates
  ]
}

## Cloudtrail ##

## S3 Bucket for ALB ##

resource "aws_s3_bucket" "alb_bucket" {
  bucket = var.alb_bucket_name
#  acl    = "private"
#  tags   = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-${var.backet_name}", Role = "S3" })
}

resource "aws_s3_bucket_acl" "alb_buc_acl1" {
  bucket = "${aws_s3_bucket.alb_bucket.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_buc_enc1" {
  bucket = "${aws_s3_bucket.alb_bucket.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

resource "aws_s3_bucket_policy" "policy_for_alb" {
  bucket = aws_s3_bucket.alb_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.alb_account_id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}/${var.alb_log_prefix}/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}/${var.alb_log_prefix}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}"
        }
    ]
}
POLICY
}



### S3 Bucket for Cloudtrail ###

resource "aws_s3_bucket" "bucket_cloudtrail" {
  bucket = "hipaatest-client-cloudtrail-logs1"
  
#  lifecycle {
#    prevent_destroy = true
#  }
  
}

resource "aws_s3_bucket_acl" "acl1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

resource "aws_s3_bucket_versioning" "public_bucket_versioning1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  versioning_configuration {
    status =   "Enabled"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_cloudtrail" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"

  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Id": "AWSCloudTrailAccessToBucket",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "cloudtrail.amazonaws.com"
        ]
    },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1"
    },

    {
      "Sid": "AWSCloudTrailWrite20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "cloudtrail.amazonaws.com"
        ]
    },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}
      }
    },

    {
      "Sid": "DenyUnEncryptedObjectUploads1",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "Bool": {"aws:SecureTransport": "false"}
      }
    },

    {
      "Sid": "RestrictDeleteActions",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:Delete*",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*"
    },

    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "StringNotEquals": {"s3:x-amz-server-side-encryption": "AES256"}
      }
    }
    ]
})
}

## Cloudwatch log group for cloudtrail ##

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "cloudtrail_log_group"
  retention_in_days = "365"
  depends_on = [
    aws_sns_topic.user_updates, 
  ]
}

## IAM Role for Cloudtrail ##

resource "aws_iam_role" "role_for_cloudwatch" {
  name = "cloudwatch-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowFlowLogs"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}



resource "aws_iam_role_policy" "iam_policy_cloudwatch" {
  name = "cloudwatch-limited-actions"
  role = aws_iam_role.role_for_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AWSCloudTrailCreateLogStream20141101"
        Action = [
          "logs:CreateLogStream",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:cloudtrail_log_group:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${var.region}*"
      },
        
      {
        Sid = "AWSCloudTrailPutLogEvents20141101"
        Action = [
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:cloudtrail_log_group:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${var.region}*"
      },
    ]
  })
  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_log_group
  ]
}

## Cloudtrail ##

resource "aws_cloudtrail" "cloudtrail" {
  name = "cloudtrail"
  s3_bucket_name = aws_s3_bucket.bucket_cloudtrail.id
  enable_logging = "true"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.role_for_cloudwatch.arn
  enable_log_file_validation = "true"
  include_global_service_events = "true"
#  sns_topic_name = aws_sns_topic.user_updates.name
  depends_on = [
    aws_s3_bucket_policy.bucket_policy_cloudtrail, aws_s3_bucket.bucket_cloudtrail, aws_cloudwatch_log_group.cloudtrail_log_group, aws_iam_role_policy.iam_policy_cloudwatch, aws_iam_role.role_for_cloudwatch, aws_sns_topic.user_updates, aws_sns_topic_policy.default
  ]

}

## Cloudwatch log metrics ##

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail" {
  name           = "Cloudtrail-metric-CloudTrailChangeCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.eventSource = cloudtrail.amazonaws.com) && (($.eventName != Describe*) && ($.eventName != Get*) && ($.eventName != Lookup*) && ($.eventName != List*))}"

  metric_transformation {
    name      = "CloudTrailChangeCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail1" {
  name           = "Cloudtrail-metric-NewAccessKeyCreated"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.eventName = CreateAccessKey)}"

  metric_transformation {
    name      = "NewAccessKeyCreated"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail2" {
  name           = "Cloudtrail-metric-IAMPolicyEventCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) ||  ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) ||  ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}"

  metric_transformation {
    name      = "IAMPolicyEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail3" {
  name           = "Cloudtrail-metric-RootUserPolicyEventCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.userIdentity.type = Root) && ($.userIdentity.invokedBy NOT EXISTS) && ($.eventType != AwsServiceEvent)}"

  metric_transformation {
    name      = "RootUserPolicyEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail4" {
  name           = "Cloudtrail-metric-NetworkAclEventCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation)}"

  metric_transformation {
    name      = "NetworkAclEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail5" {
  name           = "Cloudtrail-metric-SecurityGroupEventCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"

  metric_transformation {
    name      = "SecurityGroupEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "filter_for_cloudtrail6" {
  name           = "Cloudtrail-metric-UnauthorizedAttemptCount"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{($.errorCode=AccessDenied) || ($.errorCode=UnauthorizedOperation)}"

  metric_transformation {
    name      = "UnauthorizedAttemptsEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmCloudTrailChange" {
  alarm_name                = "cloudtrail-change-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CloudTrailChangeCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: Changes to CloudTrail log configuration detected in this account."
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on  = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmIAMCreateAccessKey" {
  alarm_name                = "iam-create-access-key-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "NewAccessKeyCreated"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: New IAM access key was created. Please be sure this action was neccessary."
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail1,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmIAMPolicyChange" {
  alarm_name                = "iam-policy-change-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "IAMPolicyEventCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: IAM Configuration changes detected!"
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail2,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmIAMRootActivity" {
  alarm_name                = "iam-root-activity-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "RootUserPolicyEventCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: Root user activity detected!"
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail3,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmNetworkACLChanges" {
  alarm_name                = "network-acl-changes-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "NetworkAclEventCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: Network ACLs have changed!"
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail4,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmSecurityGroupChanges" {
  alarm_name                = "security-group-changes-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SecurityGroupEventCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: Security Groups have changed!"
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail5,
  ]
}

resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarmUnauthorizedAttempts" {
  alarm_name                = "unauthorized-attempts-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnauthorizedAttemptsEventCount"
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Warning: Unauthorized Attempts have been detected!"
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  actions_enabled           = "true"
  depends_on = [
    aws_cloudwatch_log_metric_filter.filter_for_cloudtrail6,
  ]
}


### IAM Role for Cloudtrail ###

resource "aws_iam_role" "role_for_cloudtrail" {
  name = "cloudtrail-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowFlowLogs"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "iam_policy_cloudtrail" {
  name = "cloudtrail-limited-actions1"
  role = aws_iam_role.role_for_cloudtrail.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::hipaatest-client-cloudwatch-logs"
      },
        
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::hipaatest-client-cloudwatch-logs/*"
      },
    ]
  })
}



resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.role_for_cloudtrail.name
  path = "/"
}

#######
#######
##### S3 Cloudwatch #####

resource "aws_s3_bucket" "bucket_cloudwatch" {
  bucket = "hipaatest-client-cloudwatch-logs"
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}
resource "aws_s3_bucket_versioning" "public_bucket_versioning" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  versioning_configuration {
    status =   "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket_cloudwatch.id
  rule {
    id     = "Keep" #name of lifecycle 
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
  
#resource "aws_s3_bucket_policy" "bucket_policy" {
#  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
#
#  policy = jsonencode(
#{
#  "Version": "2012-10-17",
#  "Id": "AWSCloudTrailAccessToBucket",
#  "Statement": [
#    {
#      "Sid": "AWSCloudTrailWrite20150319",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": [
#            "vpc-flow-logs.amazonaws.com"
#        ]
#    },
#      "Action": "s3:PutObject",
#      "Resource": "arn:aws:s3:::hipaatest-client-cloudwatch-logs/*",
#    },
#    ]
#})  
#}




### flow log to s3 ###

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