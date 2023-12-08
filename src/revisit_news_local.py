from revisit_news_function import handler

event = {
    "version": "0",
    "id": "418c5c20-dd22-c047-ab99-94c0e2b2bc71",
    "detail-type": "get_top_news_success",
    "source": "lambdapythontemplate.gettopnewsfunction",
    "account": "924586450630",
    "time": "2023-12-08T17:07:45Z",
    "region": "us-east-1",
    "resources": [],
    "detail": {
        "s3_bucket": "924586450630-data-lake",
        "s3_key": "news/nytimes/mostpopular/emailed/1/2023/12/08/2023-12-08-news.json",
        "formatted_date": "2023-12-08",
    },
}


def run_local():
    handler(event, None)


run_local()
