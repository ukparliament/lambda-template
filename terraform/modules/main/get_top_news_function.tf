# ------------------------------------------------------------------------------
# get_top_news Lambda function
# ------------------------------------------------------------------------------

locals {
  get_top_news_id = "${local.id}-get-top-news"
  get_top_news_desc = "Fetches trending news stories and writes a record to S3"
  top_news_event_source = "lambdapythontemplate.gettopnewsfunction"
}

# ------------------------------------------------------------------------------
# Revisit Prediction Lambda Function
# ------------------------------------------------------------------------------

module "get_top_news_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.get_top_news_id
  description   = local.get_top_news_desc
  handler       = "get_top_news_function.handler"
  runtime       = "python3.10"
  publish       = true
  timeout       = 30

  source_path = "../../../src"

  #vpc_subnet_ids         = var.private_subnets # var.public_subnets #
  #vpc_security_group_ids = [aws_security_group.revisit_prediction.id]
  #attach_network_policy  = true

  environment_variables = {
    Serverless = "Terraform"
    API_KEY = var.news_api_key
    EVENT_BUS_NAME = data.aws_ssm_parameter.event_bus_name.value
    S3_BUCKET_NAME = data.aws_ssm_parameter.data_lake_s3_bucket_name.value
  }

  tags = local.tags
}

resource "aws_iam_policy" "get_top_news" {
  name = local.get_top_news_id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [data.aws_ssm_parameter.data_lake_s3_bucket_arn.value]
      },
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : ["${data.aws_ssm_parameter.data_lake_s3_bucket_arn.value}/news/*"]
      },
      {
        "Sid" : "PutEvents",
        "Effect" : "Allow",
        "Action" : "events:PutEvents",
        "Resource" : [data.aws_ssm_parameter.event_bus_arn.value],
        "Condition": {
          "StringEqualsIfExists": {
            "events:source": local.top_news_event_source
          }
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "get_top_news" {
  role       = module.get_top_news_lambda.lambda_role_name
  policy_arn = aws_iam_policy.get_top_news.arn
}

resource "aws_cloudwatch_event_rule" "get_top_news" {
  name        = local.get_top_news_id
  description = local.get_top_news_desc

  schedule_expression = "cron(45 5 * * ? *)"

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "get_top_news" {
  target_id = "Yada"
  rule      = aws_cloudwatch_event_rule.get_top_news.name
  arn       = module.get_top_news_lambda.lambda_function_arn
}

resource "aws_lambda_permission" "get_top_news_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.get_top_news_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_top_news.arn
}
