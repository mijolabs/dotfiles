# Add Homebrew and ~/.local/bin to PATH
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

# Create .zcompdump files in zsh cache dir instead of in $HOME
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Disable exiting on CTRL-D
setopt ignore_eof
