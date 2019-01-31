variable "clients_number" {
  default = 0
}

variable "clients_type" {
  type    = "string"
  default = "c5.large"
}

variable "frontends_number" {
  default = 1
}

variable "frontends_type" {
  type    = "string"
  default = "c5.large"
}

variable "schedulers_number" {
  default = 1
}

variable "schedulers_type" {
  type    = "string"
  default = "c5.large"
}

variable "storage_number" {
  default = 1
}

variable "storage_type" {
  type    = "string"
  default = "c5d.2xlarge"
}

variable "workers_number" {
  default = 1
}

variable "workers_type" {
  type    = "string"
  default = "c5.4xlarge"
}
