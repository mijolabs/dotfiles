#!/usr/bin/env zsh

BOOTSTRAP_SCRIPTS=("bootstrap-preferences.sh" "bootstrap-system.sh" "bootstrap-homebrew.sh")

for script in $BOOTSTRAP_SCRIPTS; do
  if [ -f $script ]; then
    chmod +x $script
    ./$script
  else
    echo "Bootstrap script $script not found."
  fi
done
