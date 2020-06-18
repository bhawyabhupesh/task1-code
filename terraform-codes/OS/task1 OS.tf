// ec2 instance

resource "aws_instance" "task1_os" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name   = "task1_key"
  vpc_security_group_ids = ["${aws_security_group.task1_sg.id}"]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.task1_private_key.private_key_pem
    host     = aws_instance.task1_os.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd"
    ]
  }
  
  tags = {
    Name = "task1_os"
  }

}



output "myos_ip" {
  value = aws_instance.task1_os
}