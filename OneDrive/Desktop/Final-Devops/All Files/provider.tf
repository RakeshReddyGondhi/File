terraform {
  backend "s3" {
    bucket         = "final-rakesh-provider.tf"
    key            = "terraform.tfstate"
    region         = "us-east-1"
     encrypt        = true
  }
}

