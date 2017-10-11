#!/bin/bash
version=$CONTRAIL_VERSION
registry=$CONTRAIL_REGISTRY
repository=$CONTRAIL_REPOSITORY

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
env_file="$DIR/../common.env"

function get_value () {
  local name=$1
  local file=$2
  echo $(awk -F'=' '$1 ~ /^'$name'$/ {gsub(/"/, "", $2); print $2}' $file)
}

if [ -f $env_file ]; then
  if [ -z $version ]; then
    version=$(get_value "CONTRAIL_VERSION" $env_file)
  fi
  if [ -z $registry ]; then
    registry=$(get_value "CONTRAIL_REGISTRY" $env_file)
  fi
  if [ -z $repository ]; then
    repository=$(get_value "CONTRAIL_REPOSITORY" $env_file)
  fi
fi

version=${version:-'4.0.1.0-32'}
registry=${registry:-'local-auto'}
repository=${repository:-'local-auto'}

if [[ $registry == 'local-auto' || $repository == 'local-auto' ]]; then
  default_interface=`ip route show | grep "default via" | awk '{print $5}'`
  my_address=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
  if [ $registry == 'local-auto' ]; then
    registry=$my_address':5000'
  fi
  if [ $repository == 'local-auto' ]; then
    repository='http://'$my_address'/'$version
  fi
fi

