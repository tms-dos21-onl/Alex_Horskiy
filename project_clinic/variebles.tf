variable "project_id" {
  description = "ID of the GCP project"
}

variable "region" {
  description = "Region for GCP resources"
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for GCP resources"
  default     = "us-central1-a"
}

variable "ssh_user" {
  description = "SSH username"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
}

variable "db_password" {
  description = "Password for the database user"
}
