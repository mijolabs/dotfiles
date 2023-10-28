#!/usr/bin/env zsh

PYTHON_VERSION="3.11.4"


# Copy bin folder to $HOME
cp -r ./bin ~/bin

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ../.zshrc ~/.zshrc

# Install Python
pyenv install $PYTHON_VERSION
