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

### AWS Config ###

resource "aws_s3_bucket" "AWSConfigLoggingBucket" {
  bucket = "hipaatest-awsconfig-logging-bucket"
  
#  lifecycle {
#    prevent_destroy = true
#  }

  tags = {
    Name        = "AWS Config Logging Bucket"
    Purpose     = "Security"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "forawsconfig" {
  bucket = "${aws_s3_bucket.AWSConfigLoggingBucket.id}"
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

resource "aws_s3_bucket_policy" "bucket_policy_aws_config" {
  bucket = "${aws_s3_bucket.AWSConfigLoggingBucket.id}"

  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Id": "AWSConfigAccessToBucket",
  "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "config.amazonaws.com"
        ]
    },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::hipaatest-awsconfig-logging-bucket"
    },

    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "config.amazonaws.com"
        ]
    },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hipaatest-awsconfig-logging-bucket/*",
      "Condition": {
         "StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}
      }
    },

    
    ]
})
}

resource "aws_s3_bucket" "config_template" {
  bucket = "hipaatest-awsconfig-template"
}

resource "aws_s3_object" "template_s3_uri" {
  bucket = aws_s3_bucket.config_template.id
  key = "Operational-Best-Practices-for-HIPAA-Security.yaml"
  source = "Operational-Best-Practices-for-HIPAA-Security.yaml"
  
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
