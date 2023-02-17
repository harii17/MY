## Cloudtrail ##

resource "aws_cloudtrail" "cloudtrail" {
  name = "cloudtrail"
  s3_bucket_name = aws_s3_bucket.bucket_cloudtrail.id
  enable_logging = "true"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.role_for_cloudwatch.arn
  enable_log_file_validation = "true"
  include_global_service_events = "true"
#  is_multi_region_trail = "true" 
#  sns_topic_name = aws_sns_topic.user_updates.name
  depends_on = [
    aws_s3_bucket_policy.bucket_policy_cloudtrail, aws_s3_bucket.bucket_cloudtrail, aws_cloudwatch_log_group.cloudtrail_log_group, aws_iam_role_policy.iam_policy_cloudwatch, aws_iam_role.role_for_cloudwatch, aws_sns_topic.user_updates, aws_sns_topic_policy.default
  ]

}
