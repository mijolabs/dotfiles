#!/usr/bin/env zsh

# Encrypt a font file using age. Prompts for desired passphrase.
age -p "$1" > "$1".age
