// for creating ebs storage

resource "aws_ebs_volume" "task1_ebs" {
  availability_zone = aws_instance.task1_os.availability_zone
  size              = 2
  tags = {
    Name = "task1_ebs"
  }
}

output "myebs"{
  value = aws_ebs_volume.task1_ebs
}