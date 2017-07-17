#!/bin/bash
version=4.0.1.0-23
registry=10.87.64.33:5043
opts=$2
if [ -z $1 ]; then
  for dir in `find . -type d`
  do
    if [ -f ${dir}/Dockerfile ]; then
      container_name=`echo $dir |cut -d"." -f2|tr "/" "-"`
      container_name=contrail${container_name}
      echo ${container_name}
      docker build ${opts} -t ${registry}/${container_name}:${version} ${dir}
      docker push ${registry}/${container_name}:${version}
      #docker save -o /var/lib/libvirt/images/docker/images/${container_name}-${version}.tar ${container_name}:${version}
    fi
  done
else
  container_name=`echo $1 |cut -d"." -f2|tr "/" "-"`
  container_name=contrail${container_name}
  docker build ${opts} -t ${registry}/${container_name}:${version} $1
  docker push ${registry}/${container_name}:${version}
  #docker save -o /var/lib/libvirt/images/docker/images/${container_name}-${version}.tar ${container_name}:${version}
fi
