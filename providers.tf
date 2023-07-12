terraform {
  

  required_version = ">=1.2.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
#   profile = "arn:aws:iam::<your account>:instance-profile/<your role name>" 
  
}