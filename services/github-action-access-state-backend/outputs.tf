output "iam_user_access_key_id" {
  value = aws_iam_access_key.terraform_state_backend.id
}

output "iam_user_secret_access_key" {
  value     = aws_iam_access_key.terraform_state_backend.secret
  sensitive = true
}
