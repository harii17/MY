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

#####

resource "aws_iam_role" "role_for_cloudtrail" {
  name = "ec2-s3-role"
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