#!/bin/bash
version=$(awk -F'=' '$1 ~ /^contrail_version$/ { print $2 }' ../kubernetes/manifest-vars)
registry=$(awk -F'=' '$1 ~ /^contrail_docker_registry$/ { print $2 }' ../kubernetes/manifest-vars)
opts=$2

echo 'Contrail version: '$version
echo 'Docker registry: '$registry
if [ -n "$opts" ]; then
  echo 'Options: '$opts
fi

build () {
  container_name=`echo $1 |cut -d"." -f2|tr "/" "-"`
  container_name=contrail${container_name}
  echo 'Building '$container_name
  docker build --build-arg CONTRAIL_VERSION=${version} --build-arg CONTRAIL_REGISTRY=${registry} ${opts} -t ${registry}/${container_name}:${version} $1
  docker push ${registry}/${container_name}:${version}
}

if [ -z $1 ] || [ $1 = 'all' ]; then
  for dir in `find . -type d`
  do
    if [ -f ${dir}/Dockerfile ]; then
      build $dir
    fi
  done
else
  build $1
fi
