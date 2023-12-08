import logging
import os
from datetime import date
import json
from urllib.request import Request, urlopen
import boto3

# Configure logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
formatter = logging.Formatter("%(name)s:%(levelname)s:%(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

# Get AWS SDK clients
s3_client = boto3.client("s3")
ses_client = boto3.client("ses")
ssm_client = boto3.client("ssm")

S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
SES_FROM_EMAIL_ADDRESS = os.environ["SES_FROM_EMAIL_ADDRESS"]
TO_EMAIL_ADDRESSES_PARAM_NAME = os.environ["TO_EMAIL_ADDRESSES_PARAM_NAME"]


def handler(event, context):
    logger.info(f"event={event}")
    event_detail = event["detail"]
    s3_bucket = event_detail["s3_bucket"]
    s3_key = event_detail["s3_key"]

    file = get_file_from_s3(s3_bucket, s3_key)
    recent_articles = json.loads(file)
    top_recent_articles = recent_articles[:5]

    # TODO get historical "this day in history" articles

    to_email_addresses = get_to_email_addresses()

    send_email(top_recent_articles, to_email_addresses)

    return "Success"


def get_file_from_s3(s3_bucket, s3_key):
    response = s3_client.get_object(Bucket=s3_bucket, Key=s3_key)
    object_content = response["Body"].read().decode("utf-8")
    return object_content


def get_to_email_addresses():
    response = ssm_client.get_parameter(
        Name=TO_EMAIL_ADDRESSES_PARAM_NAME,
        WithDecryption=True
    )
    to_email_addresses_json = response["Parameter"]["Value"]
    to_email_addresses = json.loads(to_email_addresses_json)
    logger.info(f"to_email_addresses={to_email_addresses}")
    return to_email_addresses


def send_email(recent_articles, to_email_addresses):
    html_list = [
        f"""<li><a href="{a['url']}">{a["title"]}</a></li>""" for a in recent_articles
    ]
    text_list = [f"""- {a["title"]}: {a['url']}\n""" for a in recent_articles]
    ses_client.send_email(
        Destination={
            "ToAddresses": to_email_addresses,
        },
        Message={
            "Body": {
                "Html": {
                    "Charset": "UTF-8",
                    "Data": f"""The following stories are most emailed NYT artices in the past day:
                    
                    <ol>
                    {"".join(html_list)}
                    </ol>
                    """,
                },
                "Text": {
                    "Charset": "UTF-8",
                    "Data": f"""The following stories are most emailed NYT artices in the past day:
                    
                     {"".join(text_list)}
                    """,
                },
            },
            "Subject": {
                "Charset": "UTF-8",
                "Data": "Most Emailed NYT Stories",
            },
        },
        Source=SES_FROM_EMAIL_ADDRESS,
    )
