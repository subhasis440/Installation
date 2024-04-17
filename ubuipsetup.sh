#!/bin/bash

# Change directory to /etc/netplan/
cd /etc/netplan/ || exit

# Make a backup of the original config file
sudo cp 00-installer-config.yaml 00-installer-config.yaml_bak

# Remove the original config file
sudo rm -rf 00-installer-config.yaml

# Open a text editor to create/edit the new config file
sudo nano /etc/netplan/00-installer-config.yaml

# Paste the network configuration into the opened file
cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml > /dev/null
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [192.168.55.10/24]
      gateway4: 192.168.55.1
      nameservers:
        addresses: [8.8.8.8, 4.2.2.2]
  version: 2
EOF

# Apply the new network configuration
sudo netplan apply
#https://www.youtube.com/watch?v=nbp9zxkmi74&t=2772s&ab_channel=TusharNiras
# Display the updated network configuration
ip a
