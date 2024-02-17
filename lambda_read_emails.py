import os
import boto3
import email
from email import policy
from email.parser import BytesParser

import logging

logger = logging.getLogger()
logger.setLevel("INFO")

s3 = boto3.client("s3")
sns = boto3.client("sns")

try:
    SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
except Exception as exc:
    logger.error(f"Error, no env variable SNS_TOPIC_ARN set. {exc}")


def forward_email_to_sns(cleaned_email):
    response = sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=cleaned_email,
        Subject="Message received in S3",
    )
    logger.info(response)


def extract_email_info(email_content: str) -> str:

    # Parse the email content
    msg = email.message_from_string(email_content)

    # Extract the sender, date, recipient, subject, and body
    sender = msg.get("From")
    date = msg.get("Date")
    recipient = msg.get("To")
    subject = msg.get("Subject")

    # Initialize variables for plain text and HTML bodies
    plain_body = ""
    html_body = ""

    # Iterate through the email parts
    for part in msg.walk():
        content_type = part.get_content_type()
        payload = part.get_payload(decode=True)

        if content_type == "text/plain":
            plain_body = payload.decode("utf-8")
        elif content_type == "text/html":
            html_body = payload.decode("utf-8")

    # Construct the cleaned email
    cleaned_email = (
        f"From: {sender}\nDate: {date}\nTo: {recipient}\nSubject: {subject}\n"
    )
    cleaned_email += f"Plain Body: {plain_body}\nHTML Body: {html_body}"

    return cleaned_email


def extract_s3_email(record: dict) -> str:

    bucket_name = record["s3"]["bucket"]["name"]
    filename = record["s3"]["object"]["key"]

    logger.info(f"New message {filename} received in S3 bucket {bucket_name}.")

    data = s3.get_object(Bucket=bucket_name, Key=filename)
    email_raw_content = data["Body"].read().decode("utf-8")

    try:
        cleaned_email = extract_email_info(email_raw_content)
    except Exception as exc:
        logger.error(
            f"Error while trying to extract the email. Sending the raw content. {exc}"
        )
        cleaned_email = email_raw_content

    return cleaned_email


def lambda_handler(event, context):
    # Each record is an object (message) that arrived in the S3
    for record in event["Records"]:
        cleaned_email = extract_s3_email(record)
        forward_email_to_sns(cleaned_email)
