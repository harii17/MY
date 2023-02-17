
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
#    prefix  = var.alb_log_prefix
    enabled = "true"
  }
  depends_on = [
    aws_security_group.alb_sg, aws_subnet.prod_pub_sub1, aws_subnet.prod_pub_sub2, aws_s3_bucket.alb_bucket, aws_launch_configuration.lc_web
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

  depends_on = [
    aws_lb_target_group.target-group-web,
  ]
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
