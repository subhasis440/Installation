sudo apt-get update
sudo apt-get install -y vim git wget nano htop fish git tree
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab
sudo mkdir -m 755 /etc/apt/keyrings

sudo apt-get install -y docker.io
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker root
sudo usermod -aG docker subh

sudo apt-get install -y curl apt-transport-https ca-certificates gnupg conntrack

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo apt update -y
sudo apt-get -y install containerd

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.14/cri-dockerd_0.3.14.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i cri-dockerd_0.3.14.3-0.ubuntu-jammy_amd64.deb
cri-dockerd --version

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

sudo sysctl fs.protected_regular=0

minikube start --driver=none


K9s

wget https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
rm k9s_Linux_amd64.tar.gz LICENSE README.md
