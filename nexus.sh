#!/bin/bash

# https://epma.medium.com/install-sonatype-nexus-3-on-ubuntu-20-04-lts-562f8ba20b98


# Download the Nexus Repository Manager OSS distribution
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract the distribution archive
tar xvzf latest-unix.tar.gz

# Move the Nexus Repository Manager directory to a convenient location
sudo mv nexus-* /opt/nexus

# Create a symbolic link for easier access
sudo ln -s /opt/nexus/bin/nexus /usr/local/bin/nexus

# Create a dedicated user for Nexus
sudo useradd -r nexus

# Change the ownership of the Nexus Repository Manager installation directory to the nexus user
sudo chown -R nexus:nexus /opt/nexus

# Create a service file for Nexus Repository Manager
sudo bash -c 'cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target                                                           

[Service]
Type=forking                                                                    
LimitNOFILE=65536                                                               
User=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT'
systemctl daemon-reload


# Enable the service
sudo systemctl enable nexus

# Start the service
sudo systemctl start nexus

