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

output "mysnap" {
  value = aws_ebs_snapshot.task1_ebs_snapshot
}