#data "aws_instance" "web" {
  
#  filter {
#  name = "image-id"
#  values = [lookup(var.web-type, "ami")]
#  }
#    depends_on = [
#      aws_launch_configuration.lc_web, aws_autoscaling_group.web-asg,
#    ]
#}

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
#  depends_on = [
#    aws_launch_configuration.lc_web
#
#  ]
  tags = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-tgt-gp-web" })
}

#resource "aws_lb_target_group_attachment" "test" {
#  target_group_arn = aws_lb_target_group.target-group-web.arn
#  target_id        = data.aws_instance.web.id
#  port             = 80
#  depends_on = [
#    aws_autoscaling_group.web-asg
#  ]
#}

