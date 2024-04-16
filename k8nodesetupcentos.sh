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
wget https://storage.googleapis.com/kubernetes-release/release/v1.28.8/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# Create install_kubadm_kublet.sh in the current directory
tee ./install_kubadm_kublet.sh > /dev/null <<'EOF'
#!/bin/bash

# Install CNI plugins
CNI_PLUGINS_VERSION="v1.3.0"
ARCH="amd64"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz

# Define the directory to download command files
DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"

# Install crictl
CRICTL_VERSION="v1.28.0"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C "$DOWNLOAD_DIR" -xz

# Install kubeadm, kubelet, kubectl and add a kubelet systemd service
KUBERNETES_VERSION="v1.28.8"
ARCH="amd64"
cd "$DOWNLOAD_DIR" || exit
sudo curl -L --remote-name-all "https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${ARCH}/{kubeadm,kubelet}"
sudo chmod +x {kubeadm,kubelet}

RELEASE_VERSION="v0.16.2"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
EOF

# Make install_kubadm_kublet.sh executable
chmod +x ./install_kubadm_kublet.sh

# Execute install_kubadm_kublet.sh from the current directory
./install_kubadm_kublet.sh

# Part 3: Enable and Start kubelet
sudo systemctl enable --now kubelet
sudo systemctl start kubelet

# add firewall
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --reload
sudo yum install -y conntrack-tools

# Verify installations
kubectl version --client
kubelet --version
kubeadm version
