locals {
  github_org                     = "abuinu"
  github_repo                    = "terraform-aws-examples"
  github_branch                  = "*"
  terraform_state_s3_bucket      = "abuinu-terraform-state-backend"
  terraform_state_dynamodb_table = "terraform-state-lock"
}
