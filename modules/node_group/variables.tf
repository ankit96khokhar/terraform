variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "environment" {
  type = string
}
variable "labels" {
  type = map(string)
  default = {}
}

variable "taints" {
    type = list(object({
      key = string
      value = string
      effect = string
    }))
    default = []
}