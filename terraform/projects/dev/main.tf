# ------------------------------------------------------------------------------
# lambda-python-template
# Example of "quick and dirty" CRON-job style Lambda functions
# These are *not* full-featured services with lots of dependencies.
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.14"

  backend "s3" {
    profile = "terraform-dev"
    region  = "us-east-1"
    bucket  = "924586450630-terraform-state"
    key     = "lambda-python-template/dev/terraform.tfstate.json"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-dev"
}

# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

module "main" {
  source = "../../modules/main"

  namespace    = "ik"
  env          = "dev"
  is_prod      = false

  # git_repo   = "ikenley/ai-app"
  # git_branch = "image" #"main"

}
