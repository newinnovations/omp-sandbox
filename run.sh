#!/bin/bash

# Resolve the script's real directory, following symlinks
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

mkdir -p ${SCRIPT_DIR}/sandbox-home

WORKSPACE=$(basename "$(pwd)")
USERNAME=$(id -un)

docker run --rm -it \
    -h sandbox \
    --user $(id -u):$(id -g) \
    -v "${SCRIPT_DIR}/sandbox-home":"/home/$USERNAME" \
    -v "$(pwd)":"/home/$USERNAME/$WORKSPACE" \
    -w "/home/$USERNAME/$WORKSPACE" \
    omp-sandbox

# Remove the (empty) workspace directory from sandbox-home after the container exits
# It was created during mounting of the workspace inside the container.
rmdir "${SCRIPT_DIR}/sandbox-home/$WORKSPACE" 2>/dev/null