resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "default-us-east-1-aws-config"
  s3_bucket_name = aws_s3_bucket.AWSConfigLoggingBucket.bucket
  depends_on = [
    aws_config_configuration_recorder.config_configuration_recorder
  ]
}

resource "aws_config_configuration_recorder" "config_configuration_recorder" {
  name     = "default-us-east-1-aws-config"
  role_arn = aws_iam_role.config.arn
}

resource "aws_config_configuration_recorder_status" "foo" {
  name       = aws_config_configuration_recorder.config_configuration_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

resource "aws_config_conformance_pack" "AWSConfigHIPAAConformancePack" {
  name = "aws-config-hipaa-conformance-pack"
  template_s3_uri = "s3://${aws_s3_bucket.config_template.bucket}/${aws_s3_object.template_s3_uri.key}"

  depends_on = [
    aws_config_configuration_recorder.config_configuration_recorder
  ]
  
}
