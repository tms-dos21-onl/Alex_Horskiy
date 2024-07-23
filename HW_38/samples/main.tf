terraform {
  required_version = "1.7.1"
  required_providers {
    google = "5.37.0"
  }
}

provider "google" {
  project = "trusty-stack-425306-p9"
  region  = "us-central1"
}

resource "google_compute_network" "main" {
  name = "lecture43"
}

resource "google_compute_router" "router" {
  name    = "lecture43-nat-router"
  network = google_compute_network.main.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "lecture43-router-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "webserver" {
  name          = "webserver"
  network       = google_compute_network.main.name
  ip_cidr_range = "10.0.0.0/24"
}

resource "random_id" "instance_suffix" {
  byte_length = 4
}

data "google_compute_image" "debian_11" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_firewall" "default" {
  name          = "lecture43-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.main.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] #My IP
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

resource "google_compute_firewall" "allow_iap" {
  name          = "lecture43-fw-allow-iap"
  direction     = "INGRESS"
  network       = google_compute_network.main.id
  source_ranges = ["35.235.240.0/20"] #My IP
  allow {
    protocol = "tcp"
    ports    = [22]
  }
  target_tags = ["allow-iap"]
}

resource "google_compute_instance_template" "main" {
  name         = "my-instance-template-${random_id.instance_suffix.hex}"
  machine_type = "n2-standard-2"
  tags         = ["allow-health-check", "allow-iap"]

  disk {
    source_image = data.google_compute_image.debian_11.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.webserver.name # !!!!

    # access_config {
    #   // Ephemeral public IP
    # }
  }
}

resource "google_compute_region_instance_group_manager" "main" {
  name               = "instance-group-manager-${random_id.instance_suffix.hex}"
  base_instance_name = "instance-group-manager-${random_id.instance_suffix.hex}"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.main.id
  }

  named_port {
    name = "http"
    port = 80
  }
}
