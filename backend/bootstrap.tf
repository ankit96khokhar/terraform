terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "ankit-eks-tf-state-12345"   # 🔴 CHANGE THIS (must be globally unique)

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name       = "terraform-state"
    ManagedBy = "terraform"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-locks"
  }
}
