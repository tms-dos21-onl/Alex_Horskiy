#!/bin/bash

#Install Variable
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
   sudo mkdir -p ${DIR_PORTAL} ${DIR_CLINIC}

#Download files
   sudo wget -P ${DIR_PORTAL} ${URL_PATIENT}
   sudo wget -P ${DIR_CLINIC} ${URL_CLINIC}

#Unzip files
   cd ${DIR_PORTAL}
   sudo tar -xzvf ${TAR_FILE_P}
   cd $(basename ${TAR_FILE_P} .tar.gz)

   cd ${DIR_CLINIC}
   sudo tar -xzvf ${TAR_FILE_C}
   cd $(basename ${TAR_FILE_C} .tar.gz)

#sudo tar -xvf ${DIR_PORTAL}/Clinic.PatientPortal.1.1.3.tar.gz -C ${DIR_PORTAL}
#sudo tar -xvf ${DIR_CLINIC}/Clinic.Portal.1.1.3.tar.gz -C ${DIR_CLINIC}

#Config MySQL
   sudo systemctl start mysql
   sudo systemctl enable mysql
   mysql -u root -e "CREATE DATABASE ${DB_NAME};"
   mysql -u root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
   mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
   mysql -u root -e "FLUSH PRIVILEGES;"

#Config DB
   sudo chmod +x .initdb.d/init_database.sh
   ./.initdb.d/init_database.sh
#Create add activated virt oraund
   python3.11 -m venv .venv
   source .venv/bin/activate

#Install Python packages
   pip3 install -r requirements.txt

#Config .env
   cat <<EOT > ${DIR_PORTAL}/.env
   DATABASE_NAME=${DB_NAME_P}
   DATABASE_USER=${DB_USER_P}
   DATABASE_PASSWORD=${DB_PASSWORD_P}
   EOT

   cat <<EOT > ${DIR_CLINIC}/.env
   DATABASE_NAME=${DB_NAME_C}
   DATABASE_USER=${DB_USER_C}
   DATABASE_PASSWORD=${DB_PASSWORD_C}
   EOT
EOT


