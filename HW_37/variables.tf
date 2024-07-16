variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "terraform-network"
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name          = string
    ip_cidr_range = string
  }))
}

variable "zones" {
  description = "List of zones for the instances"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "machine_type" {
  description = "Machine type for the instances"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Disk image for the instances"
  type        = string
  default     = "debian-cloud/debian-11"
}
