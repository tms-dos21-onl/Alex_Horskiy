# ---------- Install zabbix server/agent/front ---------- 

# ---------- Update packeges ---------- 
sudo apt update
sudo apt upgrade -y

# ---------- Install postgres ---------- 
sudo apt install postgresql -y
sudo systemctl status postgresql
sudo -i -u postgres
psql
CREATE DATABASE zabbix;
CREATE USER zabbix WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;
\q
exit

# ---------- Install zabbix ---------- 

sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# ---------- Service check ---------- 

sudo systemctl status postgresql
sudo systemctl status zabbix-server.service
sudo systemctl start zabbix-server.service
sudo systemctl status zabbix-server.service

# ---------- Continuation of installation ---------- 

sudo zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# ---------- Fixing config files ---------- 

sudo nano /etc/zabbix/zabbix_server.conf # Uncomment and enter values --> DBPassword=password
sudo nano /etc/zabbix/nginx.conf # Uncomment and enter values --> listen 8080 and server_name example.com;

# ---------- Start Zabbix processes ---------- 

sudo systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
sudo systemctl enable zabbix-server zabbix-agent nginx php8.1-fpm