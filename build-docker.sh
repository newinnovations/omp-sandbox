#!/bin/bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

cd "${SCRIPT_DIR}"

# NOCACHE=--no-cache

docker build $NOCACHE \
    --build-arg USERNAME=$(id -un) \
    --build-arg GROUPNAME=$(id -gn) \
    --build-arg USER_UID=$(id -u) \
    --build-arg USER_GID=$(id -g) \
    -t omp-sandbox .
