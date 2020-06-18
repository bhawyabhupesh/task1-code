// for security group

resource "aws_security_group" "task1_sg" {
  name        = "task1_sg"
  description = "Allow web requests"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "allow http requests"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "allow ssh requests"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "task1_sg"
  }
}

output "mysg" {
  value = aws_security_group.task1_sg
}