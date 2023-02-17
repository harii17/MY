resource "aws_launch_configuration" "lc_web" {
  name_prefix          = "${lookup(var.common_tags, "Stack")}-web-lc-"
#  name                 = "${lookup(var.common_tags, "Stack")}-web-lc-"
  image_id             = lookup(var.web-type, "ami")
#  image_id             = "ami-0729e439b6769d6ab"
  instance_type        = lookup(var.web-type, "type")
  ebs_optimized        = true
  security_groups      = [aws_security_group.alb_sg.id]
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  key_name             = "myKey"
  user_data            = <<-EOF
                          #!/bin/bash
                          sudo apt update && sudo apt install nginx -y
                          EOF
  root_block_device {
    device_name = "/dev/sda"
    volume_size = "8"
    volume_type = "standard"
    delete_on_termination = true
    encrypted = true
  }
#  count                = lookup(var.web_server, "active") == "true" ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_security_group.alb_sg, aws_iam_instance_profile.test_profile, aws_key_pair.kp,
  ]
}

