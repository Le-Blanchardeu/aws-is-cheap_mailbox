resource "aws_sns_topic" "forward_received_emails" {
  name = "forward-${replace(var.domain_name, ".", "_")}-received-emails"
}

resource "aws_sns_topic_subscription" "forward_to_perso_email" {
  topic_arn = aws_sns_topic.forward_received_emails.arn
  protocol  = "email"
  endpoint  = var.forward_to_perso_email
}