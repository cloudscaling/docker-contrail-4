#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/parse_env.sh"

opts=$2

echo 'Contrail version: '$version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository
if [ -n "$opts" ]; then
  echo 'Options: '$opts
fi

exit

build () {
  local container_name=`echo $1 | cut -d"." -f2 | tr "/" "-"`
  local container_name=contrail${container_name}
  echo 'Building '$container_name
  docker build -t ${registry}'/'${container_name}:${version} \
    --build-arg CONTRAIL_VERSION=${version} \
    --build-arg CONTRAIL_REGISTRY=${registry} \
    --build-arg REPO_URL=${repo_url} \
    ${opts} $1
  docker push ${registry}'/'${container_name}:${version}
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
