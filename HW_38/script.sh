#!/bin/bash

#Install packet to Clinic.Portal
sudo apt install build-essential default-libmysqlclient-dev pkg-config python3.11-dev python3.11-venv -y

#DownLoad to VM files project Clinic.Patient and Clinic.Portal

#Create dir
sudo mkdir -p /var/www/clinic/portal /var/www/clinic/patientportal

#Unzip files
sudo tar -xvf Clinic.PatientPortal.1.1.3.tar.gz -C /var/www/clinic/patientportal/
sudo tar -xvf Clinic.Portal.1.1.3.tar.gz -C /var/www/clinic/portal/

#Create BD 



