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

def handler(event, context):
    print(f"event={event}")
    logger.info(f"API_KEY={API_KEY}")
    return 'Hello world'