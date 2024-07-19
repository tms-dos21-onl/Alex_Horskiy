output "clinic_portal_ip" {
  value = google_compute_instance.clinic_portal.network_interface[0].access_config[0].nat_ip
}

output "clinic_patient_portal_ip" {
  value = google_compute_instance.clinic_patient_portal.network_interface[0].access_config[0].nat_ip
}

output "database_private_ip" {
  value = google_sql_database_instance.clinic_db.private_ip_address
}
