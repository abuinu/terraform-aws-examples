resource "aws_iam_user" "terraform_state_backend" {
  name = "terraform_state_backend"
  path = "/terraform-runner/"
}

data "aws_iam_policy_document" "terraform_state_backend" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::mybucket"]
    sid       = "AlloaListS3Bucket"
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::mybucket/path/to/my/key"]
    sid       = "AllowAccessS3Bucket"
  }
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/mytable"
    ]
    sid = "AllowAccessDynamoDB"
  }
}

resource "aws_iam_user_policy" "terraform_state_backend" {
  policy = data.aws_iam_policy_document.terraform_state_backend.json
  user   = aws_iam_user.terraform_state_backend.name
}

resource "aws_iam_access_key" "terraform_state_backend" {
  user = aws_iam_user.terraform_state_backend.name
}
