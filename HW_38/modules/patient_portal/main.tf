resource "google_compute_instance_template" "patient_template" {
  name = "patient-template"
  machine_type = "e2-medium"
  network_interface {
    network = var.network_name
    access_config {}
  }
  disks {
    boot         = true
    auto_delete  = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    echo "Hello from Patient Portal. I'm Dr.Dummy ;-)" > /var/www/html/index.html
    EOF
}

resource "google_compute_instance_group_manager" "patient_instance_group" {
  name = "patient-instance-group"
  base_instance_name = "patient-instance"
  instance_template = google_compute_instance_template.patient_template.self_link
  target_size = 1
}

output "instance_group_ip" {
  value = google_compute_instance_group_manager.patient_instance_group.instance_group
}
