.PHONY: help all _sudo-upfront macos-config xcode-clt oh-my-zsh homebrew brewfile python fonts

.DEFAULT_GOAL := help

.SILENT:

BREW_BIN_PATH := /opt/homebrew/bin


help:
	echo "Available goals:"
	grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

all: _sudo-upfront macos-config xcode-clt oh-my-zsh homebrew brewfile python fonts ## Run all setup tasks 🚀 
	echo "✅ All installations complete!"

_sudo-upfront:
	if [ "$$MAKECMDGOALS" != "all" ]; then \
		echo "❌ Only for use in 'make all'."; \
		exit 1; \
	fi
	echo "🔑 Requesting sudo upfront..."
	sudo -v

macos-config: ## Apply macOS system config
	echo "⚙️ Applying macOS system config..."
	chmod +x macos/macos-config.sh && sudo macos/macos-config.sh

xcode-clt: ## Install Xcode Command Line Tools
	if xcode-select -p >/dev/null; then \
		echo "🛠 Xcode Command Line Tools are already installed."; \
	else \
		echo "🛠 Installing Xcode Command Line Tools..."; \
		touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
		PROD=$$(softwareupdate -l | \
			grep "\*.*Command Line Tools" | \
			tail -n 1 | \
			sed -e 's/^\* Label: *//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' | tr -d '\n'); \
		sudo softwareupdate -i "$$PROD" --verbose; \
		rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
	fi

oh-my-zsh: ## Install Oh-My-Zsh
	if [ -d "$$HOME/.oh-my-zsh" ]; then \
		echo "💻 Oh-My-Zsh is already installed."; \
	else \
		echo "💻 Installing Oh-My-Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
		cp oh-my-zsh/custom/*.zsh $$HOME/.oh-my-zsh/custom/; \
		cat oh-my-zsh/.zprofile >> $$HOME/.zprofile; \
	fi

homebrew: ## Install Homebrew
	if [ -x $(BREW_BIN_PATH)/brew ]; then \
		echo "🍺 Homebrew is already installed."; \
	else \
		echo "🍺 Installing Homebrew..."; \
		sudo mkdir -p /opt/homebrew; \
		sudo chown -R $$(whoami):admin /opt/homebrew; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo 'eval "$$($(BREW_BIN_PATH)/brew shellenv)"' >> $$HOME/.zprofile; \
	fi

brewfile: homebrew ## Install packages listed in Brewfile
	if [ ! -f homebrew/Brewfile ]; then \
		echo "⚠️ Brewfile not found. Skipping package installation."; \
	else \
		echo "📦 Installing Homebrew packages from Brewfile..."; \
		$(BREW_BIN_PATH)/brew bundle --file=homebrew/Brewfile; \
	fi

python: ## Install Python
	if [ ! -x $(BREW_BIN_PATH)/uv ]; then \
		echo "⚠️ uv is not installed. Skipping Python installation."; \
	else \
		echo "🐍 Installing Python with uv..."; \
		$(BREW_BIN_PATH)/uv python install --default --preview; \
	fi

fonts: ## Decrypt and install fonts
	if [ ! -x $(BREW_BIN_PATH)/age ]; then \
		echo "⚠️ 'age' is not installed. Skipping font decryption."; \
	else \
 		FONTS_DIR="$$HOME/Library/Fonts"; \
		mkdir -p "$$FONTS_DIR"; \
		find fonts -type f -name '*.age' | while IFS= read -r f; do \
			name=$$(basename "$$f" .age); \
			echo "🔐 Decrypting $$name"; \
			$(BREW_BIN_PATH)/age --decrypt "$$f" > "$$FONTS_DIR/$$name"; \
		done; \
	fi; \
