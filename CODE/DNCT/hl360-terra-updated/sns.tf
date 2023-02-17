## SNS Topic ##

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
  fifo_topic = false
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "harikrishnan.v@dinoct.com"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_updates.arn
  
#  policy = data.aws_iam_policy_document.sns_topic_policy.json
  policy = templatefile("./sns_topic_policy.json", {})
  depends_on = [
    aws_sns_topic.user_updates
  ]
}