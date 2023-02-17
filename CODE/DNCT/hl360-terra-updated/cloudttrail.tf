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