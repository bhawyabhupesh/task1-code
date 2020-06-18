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