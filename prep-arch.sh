#!/bin/bash

swapoff -a
systemctl mask swap.target

pacman -S curl vim wget nftables 

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

pacman -S containerd 

mkdir /etc/containerd/
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1

sed  -i -e "s#SystemdCgroup = false#SystemdCgroup = true#" /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd


pacman -S  kubelet kubeadm kubectl 

systemctl enable --now kubelet 

reboot
