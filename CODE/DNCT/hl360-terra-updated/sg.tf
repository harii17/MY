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