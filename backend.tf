terraform {
  backend "s3" {
    bucket = "mybucketcaa123"
    key    = "infra.tfstate"
    region = "us-east-1"
  }
}
