#!/bin/bash

# Part 1: System Update, Docker Installation, and Containerd Installation
sudo yum update -y
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo chmod 666 /var/run/docker.sock

sudo tee /etc/yum.repos.d/containerd.repo > /dev/null <<EOF
[containerd]
name=containerd
baseurl=https://download.docker.com/linux/centos/7/\$basearch/stable
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
enabled=1
EOF
sudo yum install containerd.io -y
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo systemctl enable containerd
sudo systemctl start containerd

# Part 2: Install kubectl, kubeadm, and kubelet
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet


# add firewall

sudo yum install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=25/tcp       # SMTP (Port 25)
sudo firewall-cmd --permanent --add-port=3000-10000/tcp  # Custom TCP (Port range 3000 - 10000)
sudo firewall-cmd --permanent --add-port=80/tcp       # HTTP (Port 80)
sudo firewall-cmd --permanent --add-port=443/tcp      # HTTPS (Port 443)
sudo firewall-cmd --permanent --add-port=22/tcp       # SSH (Port 22)
sudo firewall-cmd --permanent --add-port=6443/tcp     # Custom TCP (Port 6443)
sudo firewall-cmd --permanent --add-port=465/tcp      # SMTPS (Port 465)
sudo firewall-cmd --permanent --add-port=30000-32767/tcp  # Custom TCP (Port range 30000 - 32767)
sudo firewall-cmd --permanent --add-port=9100/tcp     # Custom TCP (Port 9100)
sudo firewall-cmd --permanent --add-port=8080/tcp     # Custom TCP (Port 8080)
sudo firewall-cmd --permanent --add-port=8081/tcp     # Custom TCP (Port 8081)
sudo firewall-cmd --permanent --add-port=1000-2000/tcp   # Custom TCP (Port range 1000 - 2000)
sudo firewall-cmd --reload


# Verify installations
sudo firewall-cmd --state
kubectl version --client
kubelet --version
kubeadm version
