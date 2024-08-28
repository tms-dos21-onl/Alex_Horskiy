variable "zone" {
  description = "The zone to deploy the instance in"
  type        = string
}

variable "machine_type" {
  description = "The machine type to use for the instance"
  type        = string
}

variable "image" {
  description = "The image to use for the instance"
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to enable public IP"
  type        = bool
}

variable "delay" {
  description = "The delay duration before creating the instance"
  type        = string
  default     = "20s"
}
