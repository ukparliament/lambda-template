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
eventbridge_client = boto3.client("events")
s3_client = boto3.client("s3")

API_KEY = os.environ["API_KEY"]
EVENT_BUS_NAME = os.environ["EVENT_BUS_NAME"]
SITE_URL = (
    f"https://api.nytimes.com/svc/mostpopular/v2/emailed/1.json?api-key={API_KEY}"
)
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]


def handler(event, context):
    logger.info(f"event={event}")
    news_results = get_top_news()
    formatted_date = get_formatted_date()
    file_path = write_results_to_file(news_results, formatted_date)
    s3_key = copy_file_to_s3(file_path)
    send_event(s3_key, formatted_date)
    return "Success"


def get_top_news():
    response = urlopen(SITE_URL)
    if response.getcode() == 200:
        print("Success!")
        response_body = response.read().decode("utf-8")
        response_json = json.loads(response_body)
        results = response_json["results"]
        return results
    else:
        logger.info(f"Error: {response.getcode()}")


def get_formatted_date():
    current_date = date.today()
    formatted_date = current_date.strftime("%Y-%m-%d")
    return formatted_date


def write_results_to_file(news_results, formatted_date):
    file_path = f"/tmp/{formatted_date}-news.json"
    # Check if the directory exists, and create it if not
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)
    f = open(file_path, "w")
    f.write(json.dumps(news_results))
    f.close()
    return file_path


def copy_file_to_s3(file_path):
    file_name = os.path.basename(file_path)
    current_date = date.today()
    formatted_date = current_date.strftime("%Y/%m/%d")
    s3_key = f"news/nytimes/mostpopular/emailed/1/{formatted_date}/{file_name}"
    logger.info(f"Uploading {file_path} to s3://{S3_BUCKET_NAME}/{s3_key}")
    s3_client.upload_file(file_path, S3_BUCKET_NAME, s3_key)
    return s3_key


def send_event(s3_key, formatted_date):
    event = {
        "EventBusName": EVENT_BUS_NAME,
        "Source": "lambdapythontemplate.gettopnewsfunction",
        "DetailType": "get_top_news_success",
        "Detail": json.dumps(
            {
                "s3_bucket": S3_BUCKET_NAME,
                "s3_key": s3_key,
                "formatted_date": formatted_date,
            }
        ),
    }
    logger.info(f"Sending event: {event}")
    eventbridge_client.put_events(Entries=[event])
