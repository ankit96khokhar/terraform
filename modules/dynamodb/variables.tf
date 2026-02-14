variable "table_name" {
  type        = string
  description = "Name of DynamoDB table"
}

variable "billing_mode" {
  type        = string
  description = "Billing mode"
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
