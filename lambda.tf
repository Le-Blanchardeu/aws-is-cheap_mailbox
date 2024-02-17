# The code
data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "lambda_read_emails.py"
  output_path = "lambda_function_payload.zip"
}

# The lambda
resource "aws_lambda_function" "read_emails" {

  function_name = "lambda_read_${replace(var.domain_name, ".", "_")}_emails"
  role          = aws_iam_role.iam_for_lambda.arn
  memory_size   = 128
  timeout       = 120

  runtime          = "python3.9"
  filename         = "lambda_function_payload.zip"
  handler          = "lambda_read_emails.lambda_handler"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.forward_received_emails.arn
    }
  }

}

# The lambda role
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Lambda permission to read into the S3
data "aws_iam_policy_document" "read_s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:Get*", "s3:List*"]
    resources = ["${aws_s3_bucket.emails_storage.arn}/*", aws_s3_bucket.emails_storage.arn]
  }
}
resource "aws_iam_policy" "read_s3" {
  name        = "read_s3"
  description = "Read S3"
  policy      = data.aws_iam_policy_document.read_s3.json
}
resource "aws_iam_role_policy_attachment" "attach_read_s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.read_s3.arn
}

# Lambda permission to write logs into cloudwatch
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Lambda permission to publish in the SNS
data "aws_iam_policy_document" "publish_sns" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.forward_received_emails.arn]
  }
}
resource "aws_iam_policy" "publish_sns" {
  name        = "publish_sns"
  description = "Publish in the SNS"
  policy      = data.aws_iam_policy_document.publish_sns.json
}
resource "aws_iam_role_policy_attachment" "attach_publish_sns" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.publish_sns.arn
}