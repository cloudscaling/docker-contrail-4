#!/bin/bash

export OHOME=$HOME

sudo -u root /bin/bash << EOS

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

kubeadm init --kubernetes-version v1.7.4 --skip-preflight-checks

mkdir -p $OHOME/.kube
cp -i /etc/kubernetes/admin.conf $OHOME/.kube/config
chown -R $(id -u):$(id -g) $OHOME/.kube

EOS

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/parse-env.sh"
source "$DIR/../containers/config-docker.sh"
