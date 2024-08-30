provider "aws" {
  region = "us-west-2"
}

# Broad IAM Policy
resource "aws_iam_role" "example_role" {
  name = "example-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "example_policy" {
  name   = "example-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:GetObject",
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}

# Security Group with broad access
resource "aws_security_group" "example_sg" {
  name        = "example-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Bucket with Block Public Access
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-123456"
}

resource "aws_s3_bucket_public_access_block" "example_bucket_block" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls          = true
  ignore_public_acls          = true
  block_public_policy         = true
  restrict_public_buckets     = true
}
