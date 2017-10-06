#!/bin/sh

sudo service ufw stop
sudo iptables -F

sudo apt-get install \
      docker.io \
      apt-transport-https \
      ca-certificates \
      curl -y 

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
sudo apt-get update -y
sudo apt-get install -y kubectl
sudo apt-get install -y kubelet
sudo apt-get install -y kubeadm

sudo kubeadm init --kubernetes-version v1.7.4

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

