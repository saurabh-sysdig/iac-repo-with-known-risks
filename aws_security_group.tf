provider "aws" {
  region = "us-west-2"
}

# Public S3 Bucket with broad permissions
resource "aws_s3_bucket" "public_bucket" {
  bucket = "my-public-bucket-123456"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:*",
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.public_bucket.arn}/*",
      Principal = "*"
    }]
  })
}

# Security group allowing all traffic
resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Security group with open inbound and outbound rules."

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
