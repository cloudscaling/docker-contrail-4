#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/parse_env.sh"

echo 'Contrail version: '$version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository

CONTRAIL_VERSION=$version
CONTRAIL_REGISTRY=$registry
CONTRAIL_REPOSITORY=$repository

source "$DIR/install_repository.sh"
source "$DIR/validate_docker.sh"
source "$DIR/install_registry.sh"
