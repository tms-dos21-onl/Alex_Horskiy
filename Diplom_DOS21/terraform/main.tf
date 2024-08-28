terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.50.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.0"
    }
  }
}

provider "google" {
  project = "my-project-dos21"
  region  = "your-gcp-region"
}

data "google_compute_image" "vm_image" {
  family  = var.image_family
  project = var.image_project
}

data "http" "my_ip" {
  url = "http://ifconfig.me/ip"
}

module "vm_instances" {
  source = "./modules/instance_with_delay"

  for_each = toset(var.zone)

  zone           = each.key
  machine_type   = var.machine_type
  image          = data.google_compute_image.vm_image.self_link
  enable_public_ip = var.enable_public_ip
  delay          = "20s"
}

resource "google_compute_firewall" "allow_my_ip" {
  name    = "allow-my-ip"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  # source_ranges = [chomp(data.http.my_ip.body)]
  target_tags   = ["allow-my-ip"]
}

