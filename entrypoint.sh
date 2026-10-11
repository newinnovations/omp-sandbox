#!/bin/bash

status() {
    local color="$1"
    shift
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        printf '\033[%sm%s\033[0m\n' "$color" "$*"
    else
        printf '%s\n' "$*"
    fi
}

echo
status "1;34" "🐳 Welcome to the omp development sandbox!"

# status "0;34" "Home directory: $HOME"
# status "0;34" "Working directory: $(pwd)"

if [ -d "/seed$HOME" ] && [ ! -f "$HOME/.bashrc" ]; then
    echo
    status "0;34" "🔧 First-time run, seeding home directory from /seed$HOME"
    cp -a "/seed$HOME"/. "$HOME"/
fi

# Run the update-toolchain script to ensure the toolchain is up-to-date
# every three days and the first time the container is run.
if [ ! -f "$HOME/.toolchain_last_updated" ] || [ $(find "$HOME/.toolchain_last_updated" -mtime +3) ]; then
    /usr/local/bin/update-toolchain
fi

echo

exec "$@"
