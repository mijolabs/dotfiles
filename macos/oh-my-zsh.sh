#!/usr/bin/env zsh
set -euo pipefail


if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "⚠️  oh-my-zsh is already installed at ~/.oh-my-zsh"
  exit 0
fi

echo "🔧 Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp oh-my-zsh/. ~/

echo "✅ oh-my-zsh installed."
