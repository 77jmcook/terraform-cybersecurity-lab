
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "security_lab" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Cybersecurity-Lab-VPC"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.security_lab.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_security_group" "web_firewall" {
  name        = "lab-firewall"
  description = "Firewall for cybersecurity lab"
  vpc_id      = aws_vpc.security_lab.id

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "Cybersecurity-Lab-Firewall"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.security_lab.id

  tags = {
    Name = "Restricted-Default-Security-Group"
  }
}

resource "aws_flow_log" "security_lab" {
  vpc_id               = aws_vpc.security_lab.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flow_logs.arn
}

resource "aws_s3_bucket" "flow_logs" {
  bucket_prefix = "cybersecurity-lab-flow-logs-"

  tags = {
    Name = "Security-Flow-Logs"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    sid    = "AllowVPCFlowLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.flow_logs.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AllowLogDeliveryBucketCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.flow_logs.arn
    ]
  }
}

resource "aws_s3_bucket_policy" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}
