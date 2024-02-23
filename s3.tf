

# Creación del bucket S3
resource "aws_s3_bucket" "caa-bucket" {
  bucket = "caa-bucket-1"
  # Configuración del sitio web estático
  #website {
  #  index_document = "index.html"
  #  error_document = "error.html"
  #}
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.caa-bucket.id
  acl    = "private"
  depends_on = [ aws_s3_bucket_ownership_controls.mybucket2-acl-ownership ]
}
resource "aws_s3_bucket_ownership_controls" "mybucket2-acl-ownership" {
  bucket = aws_s3_bucket.caa-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
# Subir archivo HTML al bucket S3
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.caa-bucket.id
  key    = "index.html"
  source = "CAA.html" # Nombre del archivo HTML local
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.caa-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Creación del Origin Access Identity (OAI) para CloudFront
resource "aws_cloudfront_origin_access_identity" "example_oai" {
  comment = "OAI for example S3 bucket"
}

# Creación de la política de bucket para restringir el acceso a través de CloudFront
resource "aws_s3_bucket_policy" "caa-bucket_policy" {
  bucket = aws_s3_bucket.caa-bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

#Cloudfront
resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "my_distrib" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.caa-bucket.bucket_regional_domain_name
    origin_id                = "bucketPrimary"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "bucketPrimary"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  depends_on = [aws_s3_bucket.caa-bucket, aws_cloudfront_origin_access_control.cloudfront_s3_oac]
}