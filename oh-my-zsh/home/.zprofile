# env vars
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export PIP_REQUIRE_VIRTUALENV=true

# Disable exiting on CTRL-D
setopt ignore_eof

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# MOTD
hostname=$(hostname | cut -d . -f 1)
hostname="${(C)hostname}"
figlet -f graffiti $hostname; echo;echo;
