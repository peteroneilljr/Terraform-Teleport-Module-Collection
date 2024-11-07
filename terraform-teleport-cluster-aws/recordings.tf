/*
Configuration of S3 bucket for certs and replay
storage. Uses server side encryption to secure
session replays and SSL certificates.
*/

resource "aws_s3_bucket" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  bucket        = "${var.eks_cluster_name}-sessions-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  depends_on = [aws_s3_bucket_ownership_controls.teleport_sessions[count.index]]
  bucket     = aws_s3_bucket.teleport_sessions[count.index].bucket
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  bucket = aws_s3_bucket.teleport_sessions[count.index].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  bucket = aws_s3_bucket.teleport_sessions[count.index].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  bucket = aws_s3_bucket.teleport_sessions[count.index].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "teleport_sessions" {
  count = can(var.teleport_recordings_bucket) ? 1 : 0

  bucket = aws_s3_bucket.teleport_sessions[count.index].bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
