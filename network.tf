
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
