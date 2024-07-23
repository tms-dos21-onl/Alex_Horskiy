variable "app_name" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "load_balancer_address" {
  type = string
}

variable "load_balancer_port" {
  type = number
}

variable "ssl_certificate_self_link" {
  type = string
}
