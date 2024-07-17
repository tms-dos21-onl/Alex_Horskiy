variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "machine_type" {
  description = "Type/size of virtual machine"
  type        = string
    default     = "n1-standard-1"

}