#!/bin/bash
containers_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$containers_dir/../parse-env.sh"

container_version=$version
subver=$2
opts=$3

echo 'Contrail version: '$version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository
if [ -n "$subver" ]; then
  container_version=$version'-'$subver
  echo 'Container version: '$container_version
fi
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
  tags="-t ${registry}/${container_name}:${container_version}"
  if [ -n $subver ]; then
    tags+=" -t ${registry}/${container_name}:${version}"
  fi
  failed=0
  docker build ${tags} \
    --build-arg CONTRAIL_VERSION=${version} \
    --build-arg CONTRAIL_REGISTRY=${registry} \
    --build-arg REPOSITORY=${repository} \
    ${opts} $dir |& tee $logfile
  state=${PIPESTATUS[0]}
  test $state -eq 0 && docker push ${registry}'/'${container_name}:${container_version} |& tee -a $logfile && state=${PIPESTATUS[0]}
  test $state -eq 0 && docker push ${registry}'/'${container_name}:${version} |& tee -a $logfile && state=${PIPESTATUS[0]}
  test $state -eq 0 && rm $logfile
  if [ -f $logfile ]; then
    was_errors=1
  fi
}

if [ -z $1 ] || [ $1 = 'all' ]; then
  for dir in $(find $containers_dir -type d); do
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
