output "bucket_regional_domain_name" {
  value = aws_s3_bucket.caa-bucket.bucket_regional_domain_name
}

output "bucket_id" {
  value = aws_s3_bucket.caa-bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.caa-bucket.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.my_distrib.domain_name
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.my_distrib.arn
}