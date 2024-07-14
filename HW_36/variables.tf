variable "machine_type" {
  description = "Type/size of virtual machine"
  type        = string
}

variable "zone" {
  description = "Name availability zone"
  type        = list
}

variable "enable_public_ip" {
  description = "Boolean variable regulating creation of public IP address"
  type        = bool
  default     = false
}

variable "image_family" {
  description = "Virtual Machine Image Collection"
  type        = string
}

variable "image_project" {
  description = "Virtual machine image project"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "delay" {
  description = "The delay duration before creating the instance"
  type        = string
  default     = "20s"
}