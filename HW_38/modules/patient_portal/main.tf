resource "google_compute_instance_group_manager" "patient_instance_group" {
  #  settings for creating a virtual machine group
}

resource "google_compute_instance_template" "patient_template" {
  #  virtual machine template settings
}

output "instance_group_ip" {
  value = google_compute_instance_group_manager.patient_instance_group.instance_group
}
