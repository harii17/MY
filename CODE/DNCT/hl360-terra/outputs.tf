output "mgmt_pubsub1" {
  value = aws_subnet.mgmt_pub_sub1.id
}

output "mgmt_pubsub2" {
  value = aws_subnet.mgmt_pub_sub2.id
}

output "mgmt_pvtsub1" {
  value = aws_subnet.mgmt_pvt_sub1.id
}

output "mgmt_pvtsub2" {
  value = aws_subnet.mgmt_pvt_sub2.id
}


output "cloudwatchloggrouparn" {
  description = "cloudwatch log group arn"
  value       = aws_cloudwatch_log_group.cloudtrail_log_group.arn
}
