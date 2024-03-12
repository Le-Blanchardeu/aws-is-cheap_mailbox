# Creating the user with SMTP credentials
resource "aws_iam_user" "smtp_user" {
  name = "contact@${var.domain_name}"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender_${var.domain_name}"
  description = "Allows sending of ${var.domain_name} e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "smtp-attach" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

# Creating and verifying its identity in SES
resource "aws_ses_email_identity" "contact_email" {
  email = "contact@${var.domain_name}"
}


