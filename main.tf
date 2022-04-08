terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "policy_arn" {
  description = "IAM Policy List"
  type = list(string)
  default = [ "arn:aws:iam::<ACCOUNT-ID>:policy/<POLICY-NAME>"
                 ]
}

resource "aws_iam_role" "ebrole" {
    name = "aws-elasticbeanstalk-${var.rolename}-role"
    assume_role_policy = jsonencode({
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

resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role = aws_iam_role.ebrole.name
  count = length(var.policy_arn)
  policy_arn = var.policy_arn[count.index] 
}

resource "aws_iam_role_policy" "get_ssm_policy" {
  name = "${var.input_tags}-SSM-Parameters"
  role = aws_iam_role.ebrole.id
  policy = data.aws_iam_policy_document.get_ssm_parameters.json
}

data "aws_iam_policy_document" "get_ssm_parameters" {
  statement {
    sid = "GetSSMParameters"
    actions = [
        "ssm:GetParameter",
        ]
    resources = [
        "arn:aws:ssm:${var.region}:<ACCOUNT-ID>:parameter/${var.input_tags}*",
        ]
  }
}

resource "aws_iam_role_policy" "describe_tags_policy" {
  name = "${var.input_tags}-Describe-Tags"
  role = aws_iam_role.ebrole.id
  policy = data.aws_iam_policy_document.describe_tags.json
}

data "aws_iam_policy_document" "describe_tags" {
  statement {
    sid = "DescribeTags"
    actions = [
        "autoscaling:DescribeAutoScalingGroups",
        "ec2:DescribeTags",
        ]
    resources = [
        "*",
        ]
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "aws-elasticbeanstalk-${var.rolename}-role"
  role = aws_iam_role.ebrole.name
}
