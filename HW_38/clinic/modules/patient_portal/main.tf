locals {
  app_name = try(var.app_name, "patient-portal")
}

resource "google_service_account" "main" {
  account_id   = "${local.app_name}-id"
  display_name = "Service Account for Clinic.PatientPortal"
}

resource "google_compute_instance_template" "main" {
  name         = "${local.app_name}-template"
  description  = "This template is used to create Clinic.PatientPortal instances."
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-12"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  service_account {
    email  = google_service_account.main.email
    scopes = ["cloud-platform"]
  }

  tags = var.tags
}

resource "google_compute_region_instance_group_manager" "main" {
  name               = local.app_name
  base_instance_name = local.app_name
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.main.id
  }

  named_port {
    name = "http"
    port = 8080
  }
}

resource "google_compute_health_check" "main" {
  name                = "${local.app_name}-tcp-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port_name          = "http"
    port_specification = "USE_NAMED_PORT"
  }
}

resource "google_compute_backend_service" "main" {
  name                            = "${local.app_name}-backend-service"
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.main.id]
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  protocol                        = "HTTP"
  session_affinity                = "NONE"
  timeout_sec                     = 30

  backend {
    group           = google_compute_region_instance_group_manager.main.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "main" {
  name            = "${local.app_name}-url-map"
  default_service = google_compute_backend_service.main.id
}

resource "google_compute_target_https_proxy" "main" {
  name             = "${local.app_name}-https-proxy"
  url_map          = google_compute_url_map.main.name
  ssl_certificates = [var.ssl_certificate_self_link]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${local.app_name}-https-rule"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = var.load_balancer_port
  target                = google_compute_target_https_proxy.main.id
  ip_address            = var.load_balancer_address
}
