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
  # access_key = "AKIAYRJBGX2UBDW622XO"
  # secret_key = "Bj7k3v9sDX2zjaQ2oQekx0AO1ZZKn+u8ixYHq0pU"
  
}