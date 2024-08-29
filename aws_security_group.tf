provider "aws" {
  region = "us-west-2"
}

# 1. Public S3 Bucket
resource "aws_s3_bucket" "public_bucket" {
  bucket = "my-public-bucket-123456"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:*",
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.public_bucket.arn}/*",
          aws_s3_bucket.public_bucket.arn
        ],
        Principal = "*"
      }
    ]
  })
}

# 2. Insecure IAM Policies
resource "aws_iam_role" "insecure_role" {
  name = "insecure-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "insecure_policy" {
  name        = "insecure-policy"
  description = "A policy that grants full access to all resources."
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "insecure_policy_attachment" {
  policy_arn = aws_iam_policy.insecure_policy.arn
  role      = aws_iam_role.insecure_role.name
}

# 3. Open Security Group
resource "aws_security_group" "open_sg" {
  name        = "open-security-group"
  description = "Security group that allows all inbound traffic."

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
