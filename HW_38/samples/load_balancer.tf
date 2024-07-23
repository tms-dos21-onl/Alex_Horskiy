resource "google_compute_health_check" "default" {
  name = "lecture43-health-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "lecture43-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.main.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "default" {
  name            = "lecture43-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "lecture43-target-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_address" "default" {
  name = "lecture43-pip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "lecture43-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
