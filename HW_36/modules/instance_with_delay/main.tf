resource "time_sleep" "instance_delay" {
  create_duration = var.delay
}

resource "google_compute_instance" "vm_instance" {
  name         = "vm-instance-${var.zone}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        // Leave blank to get a dynamically assigned IP address
      }
    }
  }

  tags = ["allow-my-ip"]

  depends_on = [
    time_sleep.instance_delay
  ]
}
