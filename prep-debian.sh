#!/bin/bash

swapoff -a
systemctl mask swap.target

apt update 

apt -y install curl vim-nox gpg wget

cat <<EOF | tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter
EOF

depmod

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF

sysctl --system

apt -y install containerd

containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1

sed  -i -e "s#SystemdCgroup = false#SystemdCgroup = true#" /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


apt update
apt install kubelet kubeadm kubectl -y
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet 

reboot
