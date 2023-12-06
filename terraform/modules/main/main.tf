# ------------------------------------------------------------------------------
# Prediction application
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  id            = "${var.namespace}-${var.env}-lambda-demo"
  output_prefix = "/${var.namespace}/${var.env}/lambda-demo"

  tags = merge(var.tags, {
    Terraform   = true
    Environment = var.env
    is_prod     = var.is_prod
  })
}
