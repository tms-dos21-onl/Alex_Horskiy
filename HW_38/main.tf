provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "clinic-network"
}

module "clinic_portal" {
  source       = "./modules/clinic_portal"
  network_name = google_compute_network.vpc_network.name
  region       = var.region
}

module "patient_portal" {
  source       = "./modules/patient_portal"
  network_name = google_compute_network.vpc_network.name
  region       = var.region
}

resource "google_compute_health_check" "default" {
  name = "health-check"
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "clinic_backend" {
  name                  = "clinic-backend"
  health_checks         = [google_compute_health_check.default.id]
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.clinic_backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
}

output "clinic_portal_ip" {
  value = module.clinic_portal.instance_group_ip
}

output "patient_portal_ip" {
  value = module.patient_portal.instance_group_ip
}
