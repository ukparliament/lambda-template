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

S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
SES_FROM_EMAIL_ADDRESS = os.environ["SES_FROM_EMAIL_ADDRESS"]
TO_EMAIL_ADDRESS = os.environ["TO_EMAIL_ADDRESS"]


def handler(event, context):
    logger.info(f"event={event}")
    event_detail = json.loads(event["Detail"])
    s3_bucket = event_detail["s3_bucket"]
    s3_key = event_detail["s3_key"]

    file = get_file_from_s3(s3_bucket, s3_key)
    recent_articles = json.loads(file)
    top_recent_articles = recent_articles[:5]

    # TODO get historical "this day in history" articles

    send_email(top_recent_articles)

    return "Success"


def get_file_from_s3(s3_bucket, s3_key):
    response = s3_client.get_object(Bucket=s3_bucket, Key=s3_key)
    object_content = response["Body"].read().decode("utf-8")
    return object_content


def send_email(recent_articles):
    html_list = [
        f"""<li><a href="{a['url']}">{a["title"]}</a></li>""" for a in recent_articles
    ]
    text_list = [f"""- {a["title"]}: {a['url']}\n""" for a in recent_articles]
    ses_client.send_email(
        Destination={
            "ToAddresses": [TO_EMAIL_ADDRESS],
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
        Source=SES_FROM_EMAIL_ADDRESS
    )
