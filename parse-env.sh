#!/bin/bash
version=$CONTRAIL_VERSION
registry=$CONTRAIL_REGISTRY
repository=$CONTRAIL_REPOSITORY

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
env_file="$DIR/common.env"
if [ -f $env_file ]; then
  source $env_file
fi

version=${version:-${CONTRAIL_VERSION:-'4.0.1.0-32'}}
registry=${registry:-${CONTRAIL_REGISTRY:-'auto'}}
repository=${repository:-${CONTRAIL_REPOSITORY:-'auto'}}

if [[ $registry == 'auto' || $repository == 'auto' ]]; then
  if [ -n "$_CONTRAIL_REGISTRY_IP" ]; then
    default_ip=$_CONTRAIL_REGISTRY_IP
  else
    default_interface=`ip route show | grep "default via" | awk '{print $5}'`
    default_ip=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
  fi
  if [ $registry == 'auto' ]; then
    registry=$default_ip':5000'
  fi
  if [ $repository == 'auto' ]; then
    repository='http://'$default_ip'/'$version
  fi
fi
