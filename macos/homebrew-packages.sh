#!/bin/env zsh

set -euo


# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

brew bundle --Brewfile

echo "✅ Done installing all Homebrew packages and casks."


# Setup Python system environment
uv python install 3.13 --default --preview
