terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# AWS provider for your selected region
provider "aws" {
  region = var.aws_region

  # Authentification: [1] use AWS CLI profile or [2] env variable (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) or [3] enter hardcoded credentials below
  # profile = "default"
  # access_key = "your_aws_access_key"
  # secret_key = "your_aws_secret_access_key"

  default_tags {
    tags = {
      provisioning_method = "terraform"
      project_name        = "leblanchardeu/aws_is_cheap_mailbox"
    }
  }
}