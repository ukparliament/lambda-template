locals {
  core_output_prefix = "/${var.namespace}/${var.env}/core"
}

# Core management
data "aws_ssm_parameter" "event_bus_arn" {
  name  = "${local.core_output_prefix}/event_bus_arn"
}
data "aws_ssm_parameter" "event_bus_name" {
  name  = "${local.core_output_prefix}/event_bus_name"
}
data "aws_ssm_parameter" "ses_email_address" {
  name  = "${local.core_output_prefix}/ses_email_address"
}
data "aws_ssm_parameter" "ses_email_arn" {
  name  = "${local.core_output_prefix}/ses_email_arn"
}

# Data environment
data "aws_ssm_parameter" "data_lake_s3_bucket_arn" {
  name  = "${local.core_output_prefix}/data_lake_s3_bucket_arn"
}
data "aws_ssm_parameter" "data_lake_s3_bucket_name" {
  name  = "${local.core_output_prefix}/data_lake_s3_bucket_name"
}