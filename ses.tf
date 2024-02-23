resource "aws_ses_domain_identity" "domain_identity" {
  domain = var.domain_name
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.website_domain.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain_identity.verification_token]
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = aws_ses_domain_identity.domain_identity.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

# If you already have an active receipt rule set, you can import it:
# terraform import aws_ses_receipt_rule_set.global_rule_set enter-name-of-ruleset-here
resource "aws_ses_receipt_rule_set" "global_rule_set" {
  rule_set_name = "global_incoming_email_rule_set"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.global_rule_set.rule_set_name
}

resource "aws_ses_receipt_rule" "store" {
  name          = "store-into-emails-received-${replace(var.domain_name, ".", "_")}"
  rule_set_name = aws_ses_receipt_rule_set.global_rule_set.id
  enabled       = true
  scan_enabled  = true
  recipients = [
    var.domain_name
  ]

  s3_action {
    bucket_name = aws_s3_bucket.emails_storage.bucket
    position    = 1
  }
}