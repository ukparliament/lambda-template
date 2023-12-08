from revisit_news_function import handler

event = {
    "Source": "lambdapythontemplate.gettopnewsfunction",
    "DetailType": "get_top_news_success",
    "Detail": '{"s3_bucket": "924586450630-data-lake", "s3_key": "news/nytimes/mostpopular/emailed/1/2023/12/08/2023-12-08-news.json", "formatted_date": "2023-12-08"}',
}


def run_local():
    handler(event, None)


run_local()
