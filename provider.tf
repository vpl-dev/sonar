provider "aws" {
  region = "ap-southeast-1"
  profile = "spartan-devops"
}

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}
