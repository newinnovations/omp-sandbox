#!/bin/bash

set -eo pipefail

status() {
    local color="$1"
    shift
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        printf '\033[%sm%s\033[0m\n' "$color" "$*"
    else
        printf '%s\n' "$*"
    fi
}

export PATH="$HOME/.local/bin:$PATH"

[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

echo
status "1;33" "🔧 Starting toolchain maintenance..."
echo

if [ -f "$HOME/.cargo/bin/rustup" ]; then
    status "1;32" "🟢 Updating rust..."
    rustup update
    rustup toolchain install stable
else
    status "1;32" "🟢 Installing rust..."
    # Two steps: download and install rustup, then install the stable toolchain
    # because of https://github.com/rust-lang/rustup/issues/5059
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none 2>&1 | grep "info:"
    . "$HOME/.cargo/env"
    rustup toolchain install stable
fi

status "1;32" "✅ rust setup complete."
echo

if [ -d "$NVM_DIR" ]; then
    status "1;32" "🟢 Updating nvm and node lts..."
    cd "$NVM_DIR"
    git fetch --tags origin
    NVM_LATEST_TAG=$(git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")
    git checkout "$NVM_LATEST_TAG"
    . "$NVM_DIR/nvm.sh"
    nvm install --lts
else
    status "1;32" "🟢 Installing nvm and node lts..."
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git config advice.detachedHead false
    NVM_LATEST_TAG=$(git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")
    git checkout "$NVM_LATEST_TAG"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> "$HOME/.bashrc"
    echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> "$HOME/.bashrc"
    . "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

status "1;32" "✅ nvm setup complete."
echo

if [ -f "$HOME/.local/bin/uv" ]; then
    status "1;32" "🟢 Updating uv..."
    uv self update
else
    status "1;32" "🟢 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

status "1;32" "✅ uv setup complete."
echo

if [ -f "$HOME/.local/bin/omp" ]; then
    status "1;32" "🟢 Updating oh-my-pi..."
    omp update
else
    status "1;32" "🟢 Installing oh-my-pi..."
    curl -fsSL https://omp.sh/install | sh
fi

status "1;32" "✅ Oh-my-pi setup complete."
echo

touch "$HOME/.toolchain_last_updated"

status "1;33" "🔧 Toolchain maintenance completed successfully."