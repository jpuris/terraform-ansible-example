locals {
  aws_config_files = [pathexpand("~/.aws/config")]
  aws_credentials_files = [pathexpand("~/.aws/credentials")]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

provider "aws" {
  shared_config_files      = local.aws_config_files
  shared_credentials_files = local.aws_credentials_files
  profile                  = "terransible"
}