provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "jo-tf-state-bucket"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "Jo_TF_ApplyLock_hcl"
  }
}