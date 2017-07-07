#!/bin/bash
version=4.0.0.0-20
if [ -z $1 ]; then
  for dir in `find . -type d`
  do
    if [ -f ${dir}/Dockerfile ]; then
      container_name=`echo $dir |cut -d"." -f2|tr "/" "-"`
      container_name=contrail${container_name}
      echo ${container_name}
      docker build -t ${container_name}:${version} ${dir}
      docker save -o /var/lib/libvirt/images/docker/images/${container_name}-${version}.tar ${container_name}:${version}
    fi
  done
else
  container_name=`echo $1 |cut -d"." -f2|tr "/" "-"`
  container_name=contrail${container_name}
  docker build -t ${container_name}:${version} $1
  docker save -o /var/lib/libvirt/images/docker/images/${container_name}-${version}.tar ${container_name}:${version}
fi
