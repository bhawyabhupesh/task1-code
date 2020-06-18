// for s3 bucket object

resource "aws_s3_bucket_object" "object" {
  bucket = "task1-bucket-bs"
  key    = "singh.jpg"
  source = "/var/www/html/singh.jpg"
}