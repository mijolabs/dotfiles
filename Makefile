.PHONY: all bootstrap macos-defaults oh-my-zsh homebrew python fonts help

all: help

help:
	@echo "🛠  Dotfiles Makefile Usage:"
	@echo ""
	@echo "  make bootstrap           - Run all installation steps"
	@echo "  make macos-defaults      - Set macOS system defaults"
	@echo "  make oh-my-zsh           - Install oh-my-zsh"
	@echo "  make homebrew            - Install Homebrew and packages"
	@echo "  make python              - Install latest Python version (requires uv)"
	@echo "  make fonts               - Install custom fonts (requires age)"
	@echo ""

bootstrap: macos-defaults oh-my-zsh homebrew python fonts
	@echo "🚀 macOS system bootstrapped!"

macos-defaults:
	@echo "⚙️ Applying macOS system defaults..."
	@chmod +x macos/macos-defaults.sh && sudo macos/macos-defaults.sh

oh-my-zsh:
	@echo "💻 Installing oh-my-zsh..."
	@chmod +x macos/oh-my-zsh.sh && macos/oh-my-zsh.sh

homebrew:
	@echo "🔧 Installing Homebrew and packages..."
	@chmod +x macos/homebrew.sh && macos/homebrew.sh

python:
	@echo "🐍 Installing latest Python version with uv..."
	@chmod +x macos/python.sh && macos/python.sh

fonts:
	@echo "🔤 Installing fonts..."
	@chmod +x macos/fonts.sh && macos/fonts.sh
