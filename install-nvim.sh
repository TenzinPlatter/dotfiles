#!/bin/bash
set -e

INSTALL_DIR="/opt/nvim"
BIN_DIR="/usr/local/bin"
DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz"

# Create install directory
sudo mkdir -p $INSTALL_DIR

# Download and extract Neovim
curl -L $DOWNLOAD_URL | sudo tar -xz -C $INSTALL_DIR --strip-components=1

# Create symlink
sudo ln -sf $INSTALL_DIR/bin/nvim $BIN_DIR/nv

# Verify installation
if command -v nv >/dev/null 2>&1; then
    nv --version | head -1
else
    exit 1
fi

if command -v apt &>/dev/null; then
    sudo apt-get update || echo "Warning: update failed, continuing..."
    sudo apt-get install -y unzip python3-venv python3 ripgrep || echo "Warning: Some apt packages failed to install, continuing..."
fi
