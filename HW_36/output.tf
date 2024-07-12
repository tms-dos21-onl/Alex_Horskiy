output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnetworks" {
  value = google_compute_subnetwork.subnetworks[*].name
}

output "instance_names" {
  value = google_compute_instance.vm_instances[*].name
}

