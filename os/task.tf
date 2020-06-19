provider "aws" {
  region  = "ap-south-1"
  profile = "BHUPESH"
}

// for using default value of vpc
 
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

// for creating key to attach with ec2 instance at the time of launching

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

// for creating security group

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

// for launching OS

resource "aws_instance" "task1_os" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name   = "task1_key"
  vpc_security_group_ids = ["${aws_security_group.task1_sg.id}", "${data.aws_security_group.default.id}"]
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

// for creating ebs storage

resource "aws_ebs_volume" "task1_ebs" {
  availability_zone = aws_instance.task1_os.availability_zone
  size              = 2
  tags = {
    Name = "task1_ebs"
  }
}

// for attaching volume to ec2 instance

resource "aws_volume_attachment" "ebs_att" {
  depends_on = [
    aws_ebs_volume.task1_ebs,
  ]
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.task1_ebs.id
  instance_id  = aws_instance.task1_os.id
  force_detach = true
}

// for saving public ip of instance for future use

resource "null_resource" "nulllocal1"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.task1_os.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "nullremote1"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.task1_private_key.private_key_pem
    host     = aws_instance.task1_os.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/bhawyabhupesh/web.git /var/www/html/",
      "sudo rm -f /var/www/html/*.jpg"
    ]
  }
}

resource "null_resource" "nulllocal2"  {
 
  
	provisioner "local-exec" {
	    command = "git clone https://github.com/bhawyabhupesh/web.git"
  	}
}


// for s3 bucket object
resource "aws_s3_bucket_object" "object" {
  depends_on = [
    null_resource.nulllocal1
  ]
  bucket = "task1-bucket-bs"
  
	provisioner "local-exec" {
	    command = "cd /web/"
  	}
  key    = "singh.jpg"
  source = "/var/lib/jenkins/workspace/job2/singh.jpg"
}

// ebs snapshot

resource "aws_ebs_snapshot" "task1_ebs_snapshot" {
  depends_on = [
    null_resource.nullremote1,
  ]
  volume_id = aws_ebs_volume.task1_ebs.id

  tags = {
    Name = "task1_ebs_snapshot"
  }
}


output "mykey" {
  value = aws_key_pair.task1_key.key_name
}
output "myos_ip" {
  value = aws_instance.task1_os.public_ip
}
output "myos_zone" {
  value = aws_instance.task1_os.availability_zone
}
output "myebs"{
  value = aws_ebs_volume.task1_ebs.id
}
output "mysnap"{
  value = aws_ebs_snapshot.task1_ebs_snapshot.id
}
