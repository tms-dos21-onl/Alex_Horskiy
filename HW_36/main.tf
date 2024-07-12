terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0.0" 
    }
  }

  backend "gcs" {
    bucket = "your-bucket-name"
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = file("path/to/your/credentials.json")
  project     = var.project_id
  region      = var.region
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

data "google_compute_image" "my_image" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-vm-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
    }
  }

  network_interface {
    network = "default"
    
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
      }
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "allow-external"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = [data.http.my_ip.body]
}


