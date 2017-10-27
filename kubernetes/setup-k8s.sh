#!/bin/bash

export OHOME=$HOME

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

sudo -u root /bin/bash << EOS

install_for_ubuntu () {
  service ufw stop
  iptables -F

  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

  apt-get update -y
  apt-get install -y \
    docker.io \
    apt-transport-https \
    ca-certificates \
    kubectl kubelet kubeadm
}

install_for_centos () {
  cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
     https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

  sudo setenforce 0 || true

  yum install -y kubelet-1.7.4-0 kubeadm-1.7.4-0 kubectl-1.7.4-0 docker
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet

  echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
}

case "${linux}" in
  "ubuntu" )
    install_for_ubuntu
    ;;
  "centos" )
    install_for_centos
    ;;
esac

kubeadm init --kubernetes-version v1.7.4 --skip-preflight-checks

mkdir -p $OHOME/.kube
cp -i /etc/kubernetes/admin.conf $OHOME/.kube/config
chown -R $(id -u):$(id -g) $OHOME/.kube

EOS

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"
CONTRAIL_REGISTRY=$registry
source "$DIR/../containers/config-docker.sh"
