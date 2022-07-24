resource "aws_s3_bucket" "data_team_bucket" {
  bucket = var.bucket_name
acl = "private"

server_side_encryption_configuration {
   rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
}
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Terraform: true
  }
}
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
  policy =data.aws_iam_policy_document.key_policy.json
}
data "aws_caller_identity" "current" {
  
}
data "aws_iam_policy_document" "key_policy" {
  statement {
    sid = "GrantFullAccessToRootUser"
effect = "Allow"
principals {
  type="AWS"
  identifiers=["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}
    actions = ["kms:*"]
    resources = ["*"]
  }
}
resource "aws_instance" "State_Instance" {
    ami = "ami-0022f774911c1d690"
    instance_type = "t2.micro"
    key_name = "JSL_Key"
    iam_instance_profile = aws_iam_instance_profile.S3_Ddb_instance_profile.name
    associate_public_ip_address = true
    tags = {
      "Name" = "State-Instance"
    }
  
}
resource "aws_iam_role" "ec2_s3_Ddb_role" {
  name="ec2_s3_Ddb_rw_role"
assume_role_policy = jsonencode(
{
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ec2_s3_Ddb_role_policy" {
  name = "ec2_s3_role_policy"
  role = aws_iam_role.ec2_s3_Ddb_role.id
  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1658689700964",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1658689913085",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_instance_profile" "S3_Ddb_instance_profile" {
    name = "ec2_s3_Ddb_instance_profile"
    role = aws_iam_role.ec2_s3_Ddb_role.name 
  
}
