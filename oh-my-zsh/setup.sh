#!/usr/bin/env zsh

set -eu     # Enable shell script strictness
set -x      # Enable command tracing


ln -s $PWD/home/.z* ~/

mkdir -p ~/.oh-my-zsh/custom
ln -s $PWD/home/.oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/