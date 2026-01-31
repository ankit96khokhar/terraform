resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name   # 🔴 CHANGE THIS (must be globally unique)

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name       = "terraform-state"
    ManagedBy = "terraform"
    Env = var.env
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-locks"
    Env  = var.env
  }
}
