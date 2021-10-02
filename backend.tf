terraform {
  backend "s3" {
    bucket = "terra-boxlyttle-state"
    key    = "terraform/backend"
    region = "us-east-2"
  }
}
