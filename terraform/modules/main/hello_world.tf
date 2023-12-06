# ------------------------------------------------------------------------------
# hello_world Lambda function
# Prints "Hello, world" every month
# ------------------------------------------------------------------------------

locals {
  hello_world_id = "${local.id}-hello-world"
}

# ------------------------------------------------------------------------------
# Revisit Prediction Lambda Function
# ------------------------------------------------------------------------------

module "hello_world_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.hello_world_id
  description   = "Test function which prints hello world"
  handler       = "hello_world_function.handler"
  runtime       = "python3.10"
  publish       = true
  timeout       = 10 # 30 seconds

  source_path = "../../../src"

  #vpc_subnet_ids         = var.private_subnets # var.public_subnets #
  #vpc_security_group_ids = [aws_security_group.revisit_prediction.id]
  #attach_network_policy  = true

  environment_variables = {
    Serverless = "Terraform"
    #SES_EMAIL_ADDRESS        = var.ses_email_address
  }

  tags = local.tags
}

# resource "aws_security_group" "revisit_prediction" {
#   name        = local.revisit_prediction_id
#   description = "${local.revisit_prediction_id} sg"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge(local.tags, {
#     Name = local.revisit_prediction_id
#   })
# }

# resource "aws_iam_policy" "revisit_prediction" {
#   name = local.revisit_prediction_id

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "Ses",
#         "Effect" : "Allow",
#         "Action" : ["ses:SendEmail", "ses:SendRawEmail"],
#         "Resource" : "${var.ses_email_arn}"
#       },
#       {
#         "Sid" : "SSMDescribeParameters",
#         "Effect" : "Allow",
#         "Action" : [
#           "ssm:DescribeParameters"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "SSMGetParameters",
#         "Effect" : "Allow",
#         "Action" : [
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParameterHistory",
#           "ssm:GetParametersByPath",
#         ],
#         "Resource" : [
#           "arn:aws:ssm:*:*:parameter${local.pg_connection_parm_name}"
#         ]
#       }
#     ]
#   })

#   tags = local.tags
# }

# resource "aws_iam_role_policy_attachment" "revisit_prediction" {
#   role       = module.revisit_prediction_lambda.lambda_role_name
#   policy_arn = aws_iam_policy.revisit_prediction.arn
# }

# module "revisit_prediction_eventbridge" {
#   source  = "terraform-aws-modules/eventbridge/aws"
#   version = "1.4.0"

#   #bus_name = "${var.namespace}-bus"
#   create_bus = false

#   rules = {
#     predictions = {
#       name                = local.revisit_prediction_id
#       description         = "Check predictions once daily"
#       schedule_expression = "cron(0 10 ? * * *)"
#       enabled             = true
#     }
#   }

#   targets = {
#     predictions = [
#       {
#         name = local.revisit_prediction_id
#         arn  = module.revisit_prediction_lambda.lambda_function_arn
#       }
#     ]
#   }

#   tags = var.tags
# }

# resource "aws_lambda_permission" "allow_revisit_prediction_eventbridge" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.revisit_prediction_lambda.lambda_function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = module.revisit_prediction_eventbridge.eventbridge_rule_arns["predictions"]
# }
