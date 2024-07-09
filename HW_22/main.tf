provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a networking
resource "google_compute_network" "vpc_network" {
  name = var.network_name
}

# Creating subnets through a loop
resource "google_compute_subnetwork" "subnetworks" {
  count = length(var.subnets)

  name          = element(var.subnets, count.index).name
  ip_cidr_range = element(var.subnets, count.index).ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

# Create instans though a loop
resource "google_compute_instance" "vm_instances" {
  count        = length(var.zones)
  name         = "vm-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = element(var.zones, count.index)

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = element(google_compute_subnetwork.subnetworks[*].name, count.index)
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOT
}
