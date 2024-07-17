resource "google_compute_instance_group_manager" "clinic_instance_group" {
  # settings for creating a virtual machine group
}

resource "google_compute_instance_template" "clinic_template" {
  #  virtual machine template settings
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y dotnet-sdk-3.1

    // other commands to install and configure . NET application
    EOF
}

output "instance_group_ip" {
  value = google_compute_instance_group_manager.clinic_instance_group.instance_group
}
