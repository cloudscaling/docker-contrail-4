#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/parse-env.sh"

opts=$2

echo 'Contrail version: '$version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository
if [ -n "$opts" ]; then
  echo 'Options: '$opts
fi

was_errors=0

build () {
  local dir=$1
  if [ ! -f ${dir}/Dockerfile ]; then
    if [ -d ${dir}/base ]; then
      build ${dir}/base
    fi
    return
  fi
  local container_name=`echo $dir | cut -d"." -f2 | tr "/" "-"`
  local container_name='contrail'${container_name}
  echo 'Building '$container_name
  local logfile='build-'$container_name'.log'
  docker build -t ${registry}'/'${container_name}:${version} \
    --build-arg CONTRAIL_VERSION=${version} \
    --build-arg CONTRAIL_REGISTRY=${registry} \
    --build-arg REPO_URL=${repository} \
    ${opts} $dir |& tee $logfile
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    docker push ${registry}'/'${container_name}:${version} |& tee -a $logfile
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      rm $logfile
    fi
  fi
  if [ -f $logfile ]; then
    was_errors=1
  fi
}

if [ -z $1 ] || [ $1 = 'all' ]; then
  for dir in $(find $DIR -type d); do
    if [[ $dir != *base ]]; then
      build $dir
    fi
  done
  if [ $was_errors -ne 0 ]; then
    echo 'Failed to build some containers, see log files'
  fi
else
  build $1
fi
