#!/bin/sh

apk add sed attr dialog bash bash-completion grep util-linux pciutils usbutils binutils findutils readline lsof less nano curl
sed -e "s/v3.19/edge/" \
    -e "s/#http/http/" \
        -i /etc/apk/repositories
apk update && apk upgrade


swapoff -a

sed 's/^[^#]*swap/#&/' -i /etc/fstab


apk add bash curl vim wget uuidgen

uuidgen > /etc/machine-id


cat <<EOF | tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter
EOF


modprobe overlay br_netfilter 
depmod

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF


sysctl -p


apk add containerd

rc-update add containerd default

containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1

rc-service  containerd restart 

apk add kubelet kubeadm kubectl

rc-update add kubelet default 

reboot
