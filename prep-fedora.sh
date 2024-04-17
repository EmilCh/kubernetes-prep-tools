#!/bin/bash

swapoff -a
systemctl mask swap.target

dnf update 

dnf -y install curl vim gpg wget iproute-tc 

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

dnf -y install containerd

containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1

sed  -i -e "s#SystemdCgroup = false#SystemdCgroup = true#" /etc/containerd/config.toml

systemctl restart containerd
systemctl enable --now containerd

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

dnf -y update 

dnf -y  install kubelet kubeadm kubectl

systemctl enable --now kubelet 


systemctl disable --now firewalld 


systemctl enable kubelet


reboot