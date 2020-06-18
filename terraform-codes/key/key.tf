// for creating key

resource "tls_private_key" "task1_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "task1_key" {
  key_name   = "task1_key"
  public_key = tls_private_key.task1_private_key.public_key_openssh
  tags       = {
    Name = "task1_key"
  }
}
output "mykey" {
  value = aws_key_pair.task1_key
}