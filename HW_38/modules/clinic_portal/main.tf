resource "google_compute_instance_template" "clinic_template" {
  name = "clinic-template"
  machine_type = var.machine_type

  network_interface {
    network = var.network_name
    access_config {}
  }

  disk {
    boot         = true
    auto_delete  = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
  }  

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash

    URL_PATIENT="https://github.com/tms-dos21-onl/_sandbox/releases/download/1.1.3/Clinic.PatientPortal.1.1.3.tar.gz"
    URL_CLINIC="https://github.com/tms-dos21-onl/_sandbox/releases/download/1.1.3/Clinic.Portal.1.1.3.tar.gz"
    TAR_FILE_P="Clinic.PatientPortal.1.1.3.tar.gz"
    TAR_FILE_C="Clinic.Portal.1.1.3.tar.gz"
    DIR_PORTAL="/var/www/clinic/portal" 
    DIR_CLINIC="/var/www/clinic/clinic"
    DB_USER_P="userp"
    DB_PASSWORD_P="2442"
    DB_NAME_P="db_patient"
    DB_USER_C="userc"
    DB_PASSWORD_C="2442"
    DB_NAME_C="db_clinic"

  #Crap
    apt-get update
    apt-get install -y dotnet-sdk-3.1

  #Install required packages
    sudo apt install build-essential default-libmysqlclient-dev pkg-config python3.11-dev python3.11-venv -y

  #Create DIR
    mkdir -p \$DIR_PORTAL \$DIR_CLINIC

  #Download files
    wget -P \$DIR_PORTAL \$URL_PATIENT
    wget -P \$DIR_CLINIC \$URL_CLINIC

  #Unzip files
    cd \$DIR_PORTAL
    tar -xzvf \$TAR_FILE_P
    cd $(basename \$TAR_FILE_P .tar.gz)

    cd \$DIR_CLINIC
    tar -xzvf \$TAR_FILE_C
    cd $(basename \$TAR_FILE_C .tar.gz)

  #Config MySQL
    systemctl start mysql
    systemctl enable mysql
    mysql -u root -e "CREATE DATABASE \$DB_NAME;"
    mysql -u root -e "CREATE USER '\$DB_USER'@'localhost' IDENTIFIED BY '\$DB_PASSWORD';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \$DB_NAME.* TO '\$DB_USER'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"

  #Config DB
    chmod +x .initdb.d/init_database.sh
    ./.initdb.d/init_database.sh

  #Create add activated virt oraund
    python3.11 -m venv .venv
    source .venv/bin/activate

  #Install Python packages
    pip3 install -r requirements.txt

  #Config .env
    cat <<EOT > \$DIR_PORTAL}env
    DATABASE_NAME=\$DB_NAME_P
    DATABASE_USER=\$DB_USER_P
    DATABASE_PASSWORD=\$DB_PASSWORD_P
    EOT

    cat <<EOT > \$DIR_CLINIC/.env
    DATABASE_NAME=\$DB_NAME_C
    DATABASE_USER=\$DB_USER_C
    DATABASE_PASSWORD=\$DB_PASSWORD_C
    EOT
  SCRIPT
}


resource "google_compute_instance_group_manager" "clinic_instance_group" {
  name               = "clinic-instance-group"
  base_instance_name = "clinic-instance"
  instance_template  = google_compute_instance_template.default.name
  target_size        = 2
  zone               = var.zone

  version {
    name              = "clinic-version"
    instance_template = google_compute_instance_template.clinic_template.self_link
  }
}


resource "google_compute_instance_template" "default" {
  name = "lb-backend-template"
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    mode         = "READ_WRITE"
    source_image = "projects/debian-cloud/global/images/family/debian-11"
    type         = "PERSISTENT"
  }
  labels = {
    managed-by-cnrm = "true"
  }
  machine_type = "n1-standard-1"
  metadata = {
    startup-script = "#! /bin/bash\n     sudo apt-get update\n     sudo apt-get install apache2 -y\n     sudo a2ensite default-ssl\n     sudo a2enmod ssl\n     vm_hostname=\"$(curl -H \"Metadata-Flavor:Google\" \\\n   http://169.254.169.254/computeMetadata/v1/instance/name)\"\n   sudo echo \"Page served from: $vm_hostname\" | \\\n   tee /var/www/html/index.html\n   sudo systemctl restart apache2"
  }
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network    = "global/networks/default"
    subnetwork = "regions/us-east1/subnetworks/default"
  }
  region = "us-east1"
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }
  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/pubsub", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  tags = ["allow-health-check"]
}
