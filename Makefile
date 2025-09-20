.PHONY: help all _sudo-upfront macos-config xcode-clt oh-my-zsh homebrew brewfile python fonts

.DEFAULT_GOAL := help

help:
	@echo "Available goals:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

all: _sudo-upfront macos-config xcode-clt oh-my-zsh homebrew brewfile python fonts ## Run all setup tasks 🚀 
	@echo "✅ All installations complete!"

_sudo-upfront:
	@if [ "$$MAKECMDGOALS" != "all" ]; then \
		echo "❌ Only available when running 'make all'."; \
		exit 1; \
	fi
	@echo "🔑 Requesting sudo upfront..."
	@sudo -v

macos-config: ## Apply macOS system config
	@echo "⚙️ Applying macOS system config..."
	@chmod +x macos/macos-config.sh && sudo macos/macos-config.sh

xcode-clt: ## Install Xcode Command Line Tools
	@if xcode-select -p &>/dev/null; then \
		echo "🛠 Xcode Command Line Tools are already installed."; \
	else \
		echo "🛠 Installing Xcode Command Line Tools..."; \
		touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
		PROD=$$(softwareupdate -l | \
			grep "\*.*Command Line Tools" | \
			tail -n 1 | \
			sed -e 's/^\* Label: *//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' | \
			tr -d '\n'); \
		sudo softwareupdate -i "$$PROD" --verbose; \
		rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
	fi

oh-my-zsh: ## Install Oh-My-Zsh
	@if [ -d "$$HOME/.oh-my-zsh" ]; then \
		echo "💻 Oh-My-Zsh is already installed."; \
	else \
		echo "💻 Installing Oh-My-Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
		cp oh-my-zsh/. $$HOME/; \
	fi

homebrew: ## Install Homebrew
	@if [ -x /opt/homebrew/bin/brew ]; then \
		echo "🍺 Homebrew is already installed."; \
	else \
		echo "🍺 Installing Homebrew..."; \
		sudo mkdir -p /opt/homebrew; \
		sudo chown -R $$(whoami):admin /opt/homebrew; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> $$HOME/.zprofile; \
		eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	fi

brewfile: homebrew ## Install packages listed in Brewfile
	@if [ ! -f homebrew/Brewfile ]; then \
		echo "⚠️ Brewfile not found. Skipping package installation."; \
	else \
		echo "📦 Installing Homebrew packages from Brewfile..."; \
		/opt/homebrew/bin/brew bundle --file=homebrew/Brewfile; \
	fi

python: ## Install Python
	@if [ ! -x /opt/homebrew/bin/uv ]; then \
		echo "⚠️ uv is not installed. Skipping Python installation."; \
	else \
		echo "🐍 Installing Python with uv..."; \
		/opt/homebrew/bin/uv python install --default --preview; \
	fi

fonts: ## Decrypt and install fonts
	@if [ ! -x /opt/homebrew/bin/age ]; then \
		echo "⚠️ 'age' is not installed. Skipping font decryption."; \
	else \
		echo "🔐 Decrypting and installing fonts..."; \
		FONTS_DIR="$$HOME/Library/Fonts"; \
		mkdir -p "$$FONTS_DIR"; \
		/opt/homebrew/bin/age --decrypt "fonts/TX-02-Regular.ttf.age" > "$$FONTS_DIR/TX-02-Regular.ttf"; \
	fi
