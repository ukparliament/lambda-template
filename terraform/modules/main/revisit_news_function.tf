# ------------------------------------------------------------------------------
# revisit_news Lambda function
# ------------------------------------------------------------------------------

locals {
  revisit_news_id   = "${local.id}-revisit-news"
  revisit_news_desc = "Sends email with top news from today and a historical date"
}

# ------------------------------------------------------------------------------
# Revisit Prediction Lambda Function
# ------------------------------------------------------------------------------

module "revisit_news_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.revisit_news_id
  description   = local.revisit_news_desc
  handler       = "revisit_news_function.handler"
  runtime       = "python3.10"
  publish       = true
  timeout       = 30

  source_path = "../../../src"

  environment_variables = {
    Serverless                    = "Terraform"
    EVENT_BUS_NAME                = data.aws_ssm_parameter.event_bus_name.value
    S3_BUCKET_NAME                = data.aws_ssm_parameter.data_lake_s3_bucket_name.value
    SES_FROM_EMAIL_ADDRESS        = data.aws_ssm_parameter.ses_email_address.value
    TO_EMAIL_ADDRESSES_PARAM_NAME = aws_ssm_parameter.to_email_addresses_json.name
  }

  tags = local.tags
}

resource "aws_iam_policy" "revisit_news" {
  name = local.revisit_news_id

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
        "Action" : "s3:GetObject",
        "Resource" : ["${data.aws_ssm_parameter.data_lake_s3_bucket_arn.value}/news/*"]
      },
      {
        "Sid" : "PutEvents",
        "Effect" : "Allow",
        "Action" : "events:PutEvents",
        "Resource" : [data.aws_ssm_parameter.event_bus_arn.value],
        "Condition" : {
          "StringEqualsIfExists" : {
            "events:source" : "lambdapythontemplate.revisitnewsfunction"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameters"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter"
        ],
        "Resource" : [aws_ssm_parameter.to_email_addresses_json.arn]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ses:SendEmail"
        ],
        "Resource" : [data.aws_ssm_parameter.ses_email_arn.value]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "revisit_news" {
  role       = module.revisit_news_lambda.lambda_role_name
  policy_arn = aws_iam_policy.revisit_news.arn
}

# ------------------------------------------------------------------------------
# Event trigger
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "revisit_news" {
  name        = local.revisit_news_id
  description = local.revisit_news_desc

  event_bus_name = data.aws_ssm_parameter.event_bus_name.value

  event_pattern = jsonencode({
    source = [
      local.top_news_event_source
    ]
    detail-type = [
      "get_top_news_success"
    ]
  })

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "revisit_news" {
  target_id      = local.revisit_news_id
  rule           = aws_cloudwatch_event_rule.revisit_news.name
  event_bus_name = data.aws_ssm_parameter.event_bus_name.value
  arn            = module.revisit_news_lambda.lambda_function_arn
}

resource "aws_lambda_permission" "revisit_news_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.revisit_news_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.revisit_news.arn
}
