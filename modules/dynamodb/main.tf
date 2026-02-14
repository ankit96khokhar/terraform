resource "aws_dynamodb_table" "this" {

  name         = var.table_name
  billing_mode = var.billing_mode

  hash_key  = "tenant_env"
  range_key = "cluster_name"

  attribute {
    name = "tenant_env"
    type = "S"
  }

  attribute {
    name = "cluster_name"
    type = "S"
  }

  tags = var.tags
}
