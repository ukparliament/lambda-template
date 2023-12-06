variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Project namespace to use as a base for most resources"
}

variable "env" {
  description = "Environment used for tagging images etc."
}

variable "is_prod" {
  description = ""
  type        = bool
}

# CodePipeline

# variable "code_pipeline_s3_bucket_name" {}
# variable "source_full_repository_id" {}
# variable "source_branch_name" {}
# variable "codestar_connection_arn" {}

# SES
# variable "ses_email_address" {}
# variable "ses_email_arn" {}
