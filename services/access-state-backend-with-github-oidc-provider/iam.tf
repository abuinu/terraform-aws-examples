data "aws_caller_identity" "current" {}

data "aws_dynamodb_table" "terraform_state_lock" {
  name = local.terraform_state_dynamodb_table
}

data "aws_s3_bucket" "terraform_state_backend" {
  bucket = local.terraform_state_s3_bucket
}

data "aws_iam_policy_document" "access_terraform_state_backend" {
  statement {
    sid       = "AlloaListS3Bucket"
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.terraform_state_backend.arn]
  }
  statement {
    sid = "AllowAccessS3Bucket"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${data.aws_s3_bucket.terraform_state_backend.arn}/*"]
  }
  statement {
    sid = "AllowAccessDynamoDB"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = [data.aws_dynamodb_table.terraform_state_lock.arn]
  }
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_org}/${local.github_repo}:ref:refs/heads/${local.github_branch}"]
    }
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "access_terraform_state_backend" {
  name               = "access-terraform-state-backend"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

resource "aws_iam_role_policy" "access_terraform_state_backend" {
  policy = data.aws_iam_policy_document.access_terraform_state_backend.json
  role   = aws_iam_role.access_terraform_state_backend.name
}
