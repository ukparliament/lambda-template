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