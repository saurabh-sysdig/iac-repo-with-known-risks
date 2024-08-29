provider "aws" {
  region = "us-west-2"
}

# S3 Bucket with 'authenticated-read' ACL
resource "aws_s3_bucket" "authenticated_bucket" {
  bucket = "my-authenticated-bucket-123456"
  acl    = "authenticated-read"
}

resource "aws_s3_bucket_policy" "authenticated_bucket_policy" {
  bucket = aws_s3_bucket.authenticated_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:GetObject",
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.authenticated_bucket.arn}/*",
      Principal = "*"
    }]
  })
}

# Security group with broad but not full access
resource "aws_security_group" "broad_sg" {
  name        = "broad-sg"
  description = "Security group with broad but not unrestricted rules."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
