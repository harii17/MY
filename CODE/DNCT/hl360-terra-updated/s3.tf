#alb account id
data "aws_elb_service_account" "main" {}

## S3 Bucket for ALB ##

resource "aws_s3_bucket" "alb_bucket" {
  bucket = var.alb_bucket_name
#  acl    = "private"
#  tags   = merge(var.common_tags, { Name = "${lookup(var.common_tags, "Stack")}-${var.backet_name}", Role = "S3" })
}

resource "aws_s3_bucket_acl" "alb_buc_acl1" {
  bucket = "${aws_s3_bucket.alb_bucket.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_buc_enc1" {
  bucket = "${aws_s3_bucket.alb_bucket.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

resource "aws_s3_bucket_policy" "policy_for_alb" {
  bucket = aws_s3_bucket.alb_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "AWSConsole-AccessLogs-Policy-1660553663960",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt-1660553663962",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_elb_service_account.main.arn}"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.alb_bucket_name}"
        }
    ]
}
POLICY
}



### S3 Bucket for Cloudtrail ###

resource "aws_s3_bucket" "bucket_cloudtrail" {
  bucket = "hipaatest-client-cloudtrail-logs1"
  
#  lifecycle {
#    prevent_destroy = true
#  }
  
}

resource "aws_s3_bucket_acl" "acl1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

resource "aws_s3_bucket_versioning" "public_bucket_versioning1" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"
  versioning_configuration {
    status =   "Enabled"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_cloudtrail" {
  bucket = "${aws_s3_bucket.bucket_cloudtrail.id}"

  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Id": "AWSCloudTrailAccessToBucket",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "cloudtrail.amazonaws.com"
        ]
    },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1"
    },

    {
      "Sid": "AWSCloudTrailWrite20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "cloudtrail.amazonaws.com"
        ]
    },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}
      }
    },

    {
      "Sid": "DenyUnEncryptedObjectUploads1",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "Bool": {"aws:SecureTransport": "false"}
      }
    },

    {
      "Sid": "RestrictDeleteActions",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:Delete*",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*"
    },

    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hipaatest-client-cloudtrail-logs1/*",
      "Condition": {
         "StringNotEquals": {"s3:x-amz-server-side-encryption": "AES256"}
      }
    }
    ]
})
}

resource "aws_s3_bucket" "bucket_cloudwatch" {
  bucket = "hipaatest-client-cloudwatch-logs"
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}
resource "aws_s3_bucket_versioning" "public_bucket_versioning" {
  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
  versioning_configuration {
    status =   "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket_cloudwatch.id
  rule {
    id     = "Keep" #name of lifecycle 
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
  
#resource "aws_s3_bucket_policy" "bucket_policy" {
#  bucket = "${aws_s3_bucket.bucket_cloudwatch.id}"
#
#  policy = jsonencode(
#{
#  "Version": "2012-10-17",
#  "Id": "AWSCloudTrailAccessToBucket",
#  "Statement": [
#    {
#      "Sid": "AWSCloudTrailWrite20150319",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": [
#            "vpc-flow-logs.amazonaws.com"
#        ]
#    },
#      "Action": "s3:PutObject",
#      "Resource": "arn:aws:s3:::hipaatest-client-cloudwatch-logs/*",
#    },
#    ]
#})  
#}