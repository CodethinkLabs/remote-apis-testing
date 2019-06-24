variable "ebs_optimized" {
  default = true
}

variable "node_max_size" {
  default = 2
}

variable "node_min_size" {
  default = 1
}

variable "node_type" {
  type    = string
  default = "c5.xlarge"
}

variable "cluster_id" {
  type = string
}

variable "s3_number" {
  default = 0
}

