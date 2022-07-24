provider "aws" {
  region = var.Region
}
# THis is a template for a backend 
terraform {
  backend "s3" {
    bucket = "jo-tf-state-bucket" # name of the bucket that contain the state file
    key    = "state/terraform.tfstate" # path and name of the state file
    region = "us-east-1"   # region of the bucket 
    # use dynamoDB for state locking
    dynamodb_table = "Jo_TF_ApplyLock_hcl" # name of dynamo table to use. Please make sure partition key is set to LockID 
  }
}