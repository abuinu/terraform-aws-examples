terraform {
  backend "s3" {
    bucket         = "abuinu-terraform-state-backend"
    dynamodb_table = "terraform-state-lock"
    key            = "terraform-aws-examples/access-state-backend-with-github-oidc-provider/terraform.tfstate"
    region         = "ap-northeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56"
    }
  }
  required_version = ">= 1.9.0"
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Magaged    = "terraform"
      Repository = "terraform-aws-examples"
    }
  }
}
