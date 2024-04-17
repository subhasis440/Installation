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
sudo ufw allow 30000:32767/tcp  # Custom TCP (Port range 30000 - 32767)
sudo ufw allow 9100/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 1000:2000/tcp
