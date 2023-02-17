resource "aws_autoscaling_group" "web-asg" {
  name                      = "${lookup(var.common_tags, "Stack")}-web-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 600
  default_cooldown          = 300
  termination_policies      = ["NewestInstance"]
# vpc_zone_identifier       = [var.prod_pvtsub1, var.prod_pvtsub2]
  vpc_zone_identifier       = [aws_subnet.prod_pvt_sub1.id, aws_subnet.prod_pvt_sub2.id]
  enabled_metrics           = ["GroupTerminatingInstances", "GroupMaxSize", "GroupDesiredCapacity", "GroupPendingInstances", "GroupInServiceInstances", "GroupMinSize", "GroupTotalInstances", "GroupStandbyInstances"]
  metrics_granularity       = "1Minute"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc_web.name
  load_balancers            = aws_lb_target_group.target-group-web.arn
#  count                     = lookup(var.web_server, "active") == "true" ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_launch_configuration.lc_web, aws_subnet.prod_pvt_sub1, aws_subnet.prod_pvt_sub2,
  ]
#  tags = concat(var.extra_tags, var.extra_tags_web)

}
####
resource "aws_autoscaling_notification" "sns-notification" {
  group_names = [
    aws_autoscaling_group.web-asg.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.user_updates.arn

  depends_on = [
    aws_sns_topic.user_updates
  ]
}

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

  depends_on = [
    aws_autoscaling_group.web-asg, aws_autoscaling_policy.web_scaleup_policy,
  ]
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

  depends_on = [
    aws_autoscaling_group.web-asg, aws_autoscaling_policy.web_scaledown_policy,
  ]
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