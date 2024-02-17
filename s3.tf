data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "emails_storage" {
  bucket = "emails-received-${var.domain_name}"
}

resource "aws_s3_bucket_policy" "allow_ses_to_store_emails" {
  bucket = aws_s3_bucket.emails_storage.id
  policy = data.aws_iam_policy_document.allow_ses_to_store_emails.json
}

data "aws_iam_policy_document" "allow_ses_to_store_emails" {
  statement {
    sid = "AllowSesStoreEmailsInBucket"
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.emails_storage.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:Referer"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

# Notify the lambda when an email arrived
resource "aws_s3_bucket_notification" "email_notification" {
  bucket = aws_s3_bucket.emails_storage.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.read_emails.arn
    events              = ["s3:ObjectCreated:Put"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_emails.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.emails_storage.arn
}