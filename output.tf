output "your_email_address" {
  value = aws_ses_email_identity.contact_email.email
}

output "your_smtp_server" {
  value = "email-smtp.${var.aws_region}.amazonaws.com"
}

output "your_smtp_username" {
  value = aws_iam_access_key.smtp_user.id
}

output "your_smtp_password" {
  value     = aws_iam_access_key.smtp_user.ses_smtp_password_v4
  sensitive = true
}