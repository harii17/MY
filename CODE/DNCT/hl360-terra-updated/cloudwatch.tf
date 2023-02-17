## Cloudwatch log group for cloudtrail ##

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "cloudtrail_log_group"
  retention_in_days = "365"
  depends_on = [
    aws_sns_topic.user_updates, 
  ]
}