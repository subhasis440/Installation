sudo yum install firewalld -y  # Install firewalld if not already installed
sudo systemctl start firewalld  # Start firewalld service
sudo systemctl enable firewalld  # Ensure firewalld starts on boot

# Check the current firewall rules
sudo firewall-cmd --list-all

# Allow ports
sudo firewall-cmd --permanent --add-port=25/tcp  # SMTP (Port 25)
sudo firewall-cmd --permanent --add-port=3000-10000/tcp  # Custom TCP (Port range 3000 - 10000)
sudo firewall-cmd --permanent --add-port=80/tcp  # HTTP (Port 80)
sudo firewall-cmd --permanent --add-port=443/tcp  # HTTPS (Port 443)
sudo firewall-cmd --permanent --add-port=22/tcp  # SSH (Port 22)
sudo firewall-cmd --permanent --add-port=6443/tcp  # Custom TCP (Port 6443)
sudo firewall-cmd --permanent --add-port=465/tcp  # SMTPS (Port 465)
sudo firewall-cmd --permanent --add-port=30000-32767/tcp  # Custom TCP (Port range 30000 - 32767)
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp

# Reload firewall for changes to take effect
sudo firewall-cmd --reload

# Check the updated firewall rules
sudo firewall-cmd --list-all
