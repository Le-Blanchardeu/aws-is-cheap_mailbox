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


# TODO: To finish later:
# Check if there is already an existing rule set for incoming emails.
# If yes we will use it, if not we create one
# data "aws_ses_active_receipt_rule_set" "existing_rule_set" {
# }

resource "aws_ses_receipt_rule_set" "new_global_rule_set" {
  #count         = length(data.aws_ses_active_receipt_rule_set.existing_rule_set) > 0 ? 0 : 1
  rule_set_name = "main_incoming_email_rule_set"
}

# Set it at the main rule set 
resource "aws_ses_active_receipt_rule_set" "main" {
  #count         = length(data.aws_ses_active_receipt_rule_set.existing_rule_set) > 0 ? 0 : 1
  rule_set_name = "main_incoming_email_rule_set"
}


resource "aws_ses_receipt_rule" "store" {
  name          = "store-into-emails-received-${replace(var.domain_name, ".", "_")}"
  # rule_set_name = length(data.aws_ses_active_receipt_rule_set.existing_rule_set) > 0 ? data.aws_ses_active_receipt_rule_set.existing_rule_set.id : aws_ses_receipt_rule_set.new_global_rule_set[0].id
  rule_set_name = aws_ses_receipt_rule_set.new_global_rule_set.id
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