provider "google" {
  project = var.project
  region  = var.region
}

################################## NETWORK ##################################

resource "google_compute_network" "main" {
  name                    = "clinic"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  for_each = {
    portal        = var.clinic_portal_snet
    patientportal = var.patient_portal_snet
  }

  name          = "${each.key}-subnet"
  ip_cidr_range = each.value
  region        = var.region
  network       = google_compute_network.main.self_link
}

resource "google_compute_router" "main" {
  name    = "clinic-router"
  network = google_compute_network.main.self_link
  region  = var.region
}

resource "google_compute_address" "nat" {
  count = 2

  name   = "clinic-nat-manual-ip-${count.index}"
  region = var.region
}

resource "google_compute_router_nat" "main" {
  name   = "clinic-router-nat"
  router = google_compute_router.main.name
  region = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.main["portal"].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
################################## FW RULES ##################################

resource "google_compute_firewall" "allow_health_checks" {
  name          = "fw-allow-health-check"
  direction     = "INGRESS"
  network       = google_compute_network.main.name
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]

  allow {
    ports    = ["8000", "8080"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name          = "fw-allow-iap-ssh"
  direction     = "INGRESS"
  network       = google_compute_network.main.name
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap-ssh"]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}

################################## SSL CERTIFICATE ##################################

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "main" {
  private_key_pem = tls_private_key.main.private_key_pem

  validity_period_hours = 43800 //  1825 days or 5 years

  subject {
    # The subject CN field here contains the hostname to secure
    common_name = "*.clinic.internal"
  }

  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "google_compute_ssl_certificate" "main" {
  name = "clinic"

  private_key = tls_private_key.main.private_key_pem
  certificate = tls_self_signed_cert.main.cert_pem
}

################################## LOAD BALANCER ##################################

resource "google_compute_global_address" "load_balancer" {
  name       = "clinic-lb-ipv4"
  ip_version = "IPV4"
}

################################## APPLICATIONS ##################################

module "clinic_portal" {
  source = "./modules/clinic_portal"

  region                    = var.region
  network                   = google_compute_network.main.name
  subnetwork                = google_compute_subnetwork.main["portal"].name
  tags                      = ["allow-health-check", "allow-iap-ssh"]
  load_balancer_address     = google_compute_global_address.load_balancer.address
  load_balancer_port        = 443
  ssl_certificate_self_link = google_compute_ssl_certificate.main.self_link
}

module "patient_portal" {
  source = "./modules/patient_portal"

  region                    = var.region
  network                   = google_compute_network.main.name
  subnetwork                = google_compute_subnetwork.main["patient"].name
  tags                      = ["allow-health-check", "allow-iap-ssh"]
  load_balancer_address     = google_compute_global_address.load_balancer.address
  load_balancer_port        = 8443
  ssl_certificate_self_link = google_compute_ssl_certificate.main.self_link
}
