#!/bin/bash

if [ -n "$CONTRAIL_REGISTRY" ]; then
  address=$(echo $CONTRAIL_REGISTRY | awk -F':' '{print $1}')
else
  default_interface=`ip route show |grep "default via" | awk '{print $5}'`
  address=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
fi

echo Allow docker to connect Contrail registry unsecurely
if [ $port -eq 443 ]; then
  :
else
  if [ $port -eq 80 ]; then
    remote_address=$address
  else
    remote_address=$address:$port
  fi
  printf "{\n  \"insecure-registries\" : [\"$remote_address\"]\n}" | sudo tee /etc/docker/daemon.json
  sudo service docker restart
fi

echo Allow current user to access docker directly (requires re-login)
sudo groupadd docker
sudo usermod -aG docker $USER
