provider "google" {
  project = var.project_id
  region  = var.region
}

# Создание сети
resource "google_compute_network" "clinic_network" {
  name = "clinic-network"
}

# Создание подсети
resource "google_compute_subnetwork" "clinic_subnetwork" {
  name          = "clinic-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.clinic_network.name
  region        = var.region
}

# Создание Firewall правил
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.clinic_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.clinic_network.name

  allow {
    protocol = "tcp"
    ports    = ["8000", "8443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Создание VM для clinic-portal
resource "google_compute_instance" "clinic_portal" {
  name         = "clinic-portal"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-12-bullseye-v20230613"
    }
  }

  network_interface {
    network    = google_compute_network.clinic_network.name
    subnetwork = google_compute_subnetwork.clinic_subnetwork.name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  provisioner "file" {
    source      = "Clinic.Portal.1.1.3.tar.gz"
    destination = "/home/${var.ssh_user}/Clinic.Portal.1.1.3.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt install -y build-essential default-libmysqlclient-dev pkg-config python3.11-dev python3.11-venv default-mysql-client",
      "tar -xf /home/${var.ssh_user}/Clinic.Portal.1.1.3.tar.gz -C /home/${var.ssh_user}/",
      "cd /home/${var.ssh_user}/Clinic.Portal.1.1.3",
      "python3 -m venv .venv",
      ". .venv/bin/activate",
      "pip3 install -r requirements.txt",
      "sed -i 's/DB_HOST=.*/DB_HOST=${google_sql_database_instance.clinic_db.private_ip_address}/' .env",
      "sed -i 's/ALLOWED_HOSTS=.*/ALLOWED_HOSTS=[\"*\"]/' .env",
      "python3 manage.py runserver 0.0.0.0:8000 &"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Создание VM для clinic-patient-portal
resource "google_compute_instance" "clinic_patient_portal" {
  name         = "clinic-patient-portal"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-12-bullseye-v20230613"
    }
  }

  network_interface {
    network    = google_compute_network.clinic_network.name
    subnetwork = google_compute_subnetwork.clinic_subnetwork.name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  provisioner "file" {
    source      = "Clinic.PatientPortal.1.1.3.tar.gz"
    destination = "/home/${var.ssh_user}/Clinic.PatientPortal.1.1.3.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "rm packages-microsoft-prod.deb",
      "sudo apt update && sudo apt install -y aspnetcore-runtime-6.0 dotnet-runtime-6.0",
      "tar -xf /home/${var.ssh_user}/Clinic.PatientPortal.1.1.3.tar.gz -C /home/${var.ssh_user}/",
      "cd /home/${var.ssh_user}/Clinic.PatientPortal.1.1.3",
      "openssl genrsa 2048 > cert.key",
      "chmod 400 cert.key",
      "openssl req -new -x509 -nodes -sha256 -days 365 -key cert.key -out cert.crt -subj '/CN=${google_sql_database_instance.clinic_db.private_ip_address}'",
      "sed -i 's/server=.*/server=${google_sql_database_instance.clinic_db.private_ip_address}/' appsettings.json",
      "sed -i 's/Uri=.*/\"Uri\": \"http:\/\/${google_compute_instance.clinic_portal.network_interface[0].access_config[0].nat_ip}:8000\/\"/' appsettings.json",
      "dotnet Clinic.PatientPortal.dll --urls https://0.0.0.0:8443 &"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Создание Google Cloud SQL instance
resource "google_sql_database_instance" "clinic_db" {
  name             = "clinic-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.clinic_network.self_link
    }
  }
}

# Создание базы данных
resource "google_sql_database" "clinic_database" {
  name     = "clinic"
  instance = google_sql_database_instance.clinic_db.name
}

# Создание пользователя базы данных
resource "google_sql_user" "clinic_user" {
  name     = "clinic_user"
  instance = google_sql_database_instance.clinic_db.name
  password = var.db_password
}
