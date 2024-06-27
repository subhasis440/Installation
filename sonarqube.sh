#!/bin/bash
set -e

SONARQUBE_VERSION="10.6.0.92116" # Update with the latest stable version
SONARQUBE_ZIP_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"

# Update and install necessary packages
apt update -y
apt install curl wget tree nano git zip nginx -y

# Configure system limits
cp /etc/sysctl.conf /root/sysctl.conf_backup
cat <<EOT >> /etc/sysctl.conf
vm.max_map_count=524288
fs.file-max=131072
EOT
sysctl -p

cp /etc/security/limits.conf /root/sec_limit.conf_backup
cat <<EOT >> /etc/security/limits.conf
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOT

# Apply ulimit settings for current session
ulimit -n 131072
ulimit -u 8192

# Install Java
apt update -y
apt install openjdk-17-jdk -y
java -version

# Setup PostgreSQL
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo tee /usr/share/keyrings/postgresql.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
apt update -y
apt install postgresql postgresql-contrib -y
systemctl enable postgresql
systemctl start postgresql
echo "postgres:admin123" | chpasswd
sudo -u postgres createuser sonar
sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -u postgres createdb -O sonar sonarqube
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

# Download and configure SonarQube
sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O "${SONARQUBE_ZIP_URL}"
sudo unzip -o sonarqube-${SONARQUBE_VERSION}.zip -d /opt/
sudo mv /opt/sonarqube-${SONARQUBE_VERSION}/ /opt/sonarqube
groupadd sonar
useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
chown sonar:sonar /opt/sonarqube/ -R

cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
cat <<EOT > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

cat <<EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube

# Configure Nginx
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default
cat <<EOT > /etc/nginx/sites-available/sonarqube
server {
    listen      80;
    server_name sonarqube.groophy.in;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT
ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx
systemctl restart nginx

# Firewall configuration
sudo apt install ufw -y
sudo ufw enable
sudo ufw status numbered
sudo ufw allow 25/tcp  # SMTP (Port 25)
sudo ufw allow 3000:10000/tcp  # Custom TCP (Port range 3000 - 10000)
sudo ufw allow 80/tcp  # HTTP (Port 80)
sudo ufw allow 443/tcp  # HTTPS (Port 443)
sudo ufw allow 22/tcp  # SSH (Port 22)
sudo ufw allow 6443/tcp  # Custom TCP (Port 6443)
sudo ufw allow 465/tcp  # SMTPS (Port 465)
sudo ufw allow 8080/tcp
ufw allow 9000/tcp
ufw allow 9001/tcp

# Start services
systemctl start sonarqube

echo "System reboot in 30 sec"
sleep 30
reboot
