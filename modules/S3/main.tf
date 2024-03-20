resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = true

}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_public_access_block.main,
  ]
  bucket = aws_s3_bucket.bucket.id
  acl="public-read"
}

resource "aws_iam_user" "s3" {
  name = "wordpress-midterm-s3"
}

resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

resource "aws_iam_user_policy_attachment" "s3_user_attachment" {
    user = aws_iam_user.s3.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_access_key" "s3_user" {
    user = aws_iam_user.s3.name
}

output "iam_s3_access_key" {
  value = aws_iam_access_key.s3.id
}

output "iam_s3_secret_key" {
  value = aws_iam_access_key.s3.secret
}