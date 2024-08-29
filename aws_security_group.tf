provider "aws" {
  region = "us-west-2"
}

# Overly permissive IAM Policy
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
  name        = "example-policy"
  description = "A policy with broad permissions."
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "*",
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}

# Security Group allowing broad access
resource "aws_security_group" "broad_access_sg" {
  name        = "broad-access-sg"
  description = "Security group with broad access."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Bucket with default encryption but public ACL
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-123456"
  acl    = "public-read"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example_bucket_encryption" {
  bucket = aws_s3_bucket.example_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
