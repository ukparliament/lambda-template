import logging
import os
from datetime import datetime
import json
from urllib.request import Request, urlopen

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(name)s:%(levelname)s:%(message)s')
handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(handler)

API_KEY = os.environ['API_KEY']
SITE_URL=f"https://api.nytimes.com/svc/mostpopular/v2/emailed/7.json?api-key={API_KEY}"

def handler(event, context):
    logger.info(f"event={event}")
    logger.info(f"API_KEY={API_KEY}")
    get_top_news()
    return 'Hello world'

def get_top_news():
    response = urlopen(SITE_URL)
    if response.getcode() == 200:
        print('Success!')
        response_body = response.read().decode('utf-8')
        response_json = json.loads(response_body)
        results = response_json["results"]
        return results
    else:
        logger.info(f'Error: {response.getcode()}')

