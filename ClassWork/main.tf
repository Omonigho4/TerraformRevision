#The goal was to create an  instance, create a role that has s3 read and write (Get and Put) permisions to existing S3 bucket
# add permision to the dynamoDB tabe we created if it exists.
resource "aws_instance" "State_Instance" {
    ami = var.ami #"ami-0022f774911c1d690" ami is founf in the variable .tf file
    instance_type =var.instance_type #"t2.micro"  instance type is found  in variable.tf
    iam_instance_profile = aws_iam_instance_profile.ec2_s3_Ddb_instance_profile.id # This is the instance profie we created below
    associate_public_ip_address = true
    tags = {
      "Name" = "State-Instance"
    }
}
# Here , we need to tell which service/account this role will be used
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]  # This is going to be an assume role
    principals {
      type        = "Service" # A service will be using this role . If it was an account , use "AWS"
      identifiers = ["ec2.amazonaws.com"] # Here is the name of the service that is assuming this role. if this
                                          # was an account, put the account arn here.
  }
}
}
# This is the role we grant s3 and DynamoDB access based on the permission we have in data "aws_iam_policy_document" "source"  
resource "aws_iam_role" "S3_Dynamo_role" {
  name               = "S3_Dynamo_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
inline_policy {
  policy=data.aws_iam_policy_document.source.json
} 
}
# This is the instance profile that we will use to attache the role to the instance
# Here we give the profile a name and specify what role to use
resource "aws_iam_instance_profile" "ec2_s3_Ddb_instance_profile" {
      name = "ec2_s3_Ddb_instance_profile"
    role = aws_iam_role.S3_Dynamo_role.name 
}
# These are the policies , stating what service this role can access.
# Here we are granting access to s3 and DynamoDB
# Add a statement block for every service you need access to
data "aws_iam_policy_document" "source" {
    # THis is the statement block for s3
  statement{
      sid= "s3 get and put"
      effect= "Allow"
       actions= [
        "s3:Get*",
        "s3:Put*",
        "s3:List*"
      ]
      resources = ["arn:aws:s3:::jo-tf-state-bucket/*"]
    }
    # THis is the statement block for dynamo DB
        statement{
      sid= "Dynamo access "
      effect= "Allow"
       actions= [
        "dynamodb:CreateTable",
        "dynamodb:DeleteBackup",
        "dynamodb:DeleteItem",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeBackup",
        "dynamodb:DescribeContinuousBackups",
        "dynamodb:DescribeContributorInsights",
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      resources = ["arn:aws:dynamodb:us-east-1:559048691713:table/Jo_TF_ApplyLock_hcl"]
    }
    }
