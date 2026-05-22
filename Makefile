.PHONY: help all _sudo-upfront macos-config omz xcode-clt homebrew brewfile python fonts claude-code iterm2
.DEFAULT_GOAL := help
.SILENT:

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

BOOTSTRAP_DIR := bootstrap
BREW_BIN_PATH := /opt/homebrew/bin


help:
	printf "\nAvailable goals:\n\n"
	grep -E '^[[:space:]]*[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS=":.*##"} {gsub(/^[[:space:]]*/, "", $$1); printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	printf "\nGoal descriptions prefixed with '*' are excluded when running 'make all'.\n\n"

all: _sudo-upfront macos-config xcode-clt homebrew omz brewfile python fonts claude-code iterm2 ## 🚀 Run all base setup tasks
	echo "✅ All installations complete!"


_sudo-upfront:
	if [ "$(MAKECMDGOALS)" != "all" ]; then \
		echo "❌ Only for use in 'make all'."; \
		exit 1; \
	fi
	echo "🔑 Requesting sudo upfront..."
	sudo -v
	while true; do sudo -n true; sleep 50; kill -0 "$$$$" || exit; done 2>/dev/null &

macos-config: ## Apply macOS system config
	echo "⚙️ Applying macOS system config..."
	chmod +x $(BOOTSTRAP_DIR)/macos/macos-config.sh && sudo $(BOOTSTRAP_DIR)/macos/macos-config.sh

omz: xcode-clt ## Install Oh-My-Zsh and configure shell
	if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "💻 Installing Oh-My-Zsh..."; \
		RUNZSH=no CHSH=no sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	else \
		echo "💻 Oh-My-Zsh is already installed."; \
	fi
	echo "🔗 Linking custom zsh files..."
	for f in $$(pwd)/$(BOOTSTRAP_DIR)/zsh/custom/*.zsh; do \
		name=$$(basename "$$f"); \
		dest="$$HOME/.oh-my-zsh/custom/$$name"; \
		if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$f" ]; then \
			echo "  $$name already linked."; \
		else \
			ln -sf "$$f" "$$dest"; \
			echo "  Linked $$name"; \
		fi; \
	done
	ZSHRC_SOURCE="source $$(pwd)/$(BOOTSTRAP_DIR)/zsh/zshrc.sh"; \
	if ! grep -qF "$$ZSHRC_SOURCE" "$$HOME/.zshrc" 2>/dev/null; then \
		echo "$$ZSHRC_SOURCE" > "$$HOME/.zshrc"; \
	fi
	ZPROFILE_SOURCE="source $$(pwd)/$(BOOTSTRAP_DIR)/zsh/zprofile.sh"; \
	if ! grep -qF "$$ZPROFILE_SOURCE" "$$HOME/.zprofile" 2>/dev/null; then \
		echo "$$ZPROFILE_SOURCE" >> "$$HOME/.zprofile"; \
	fi
	echo "✅ Shell configured."

xcode-clt: ## Install Xcode Command Line Tools
	if xcode-select -p >/dev/null 2>&1; then \
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

homebrew: ## Install Homebrew
	if [ -x $(BREW_BIN_PATH)/brew ]; then \
		echo "🍺 Homebrew is already installed."; \
	else \
		echo "🍺 Installing Homebrew..."; \
		sudo mkdir -p /opt/homebrew; \
		sudo chown -R $$(whoami):admin /opt/homebrew; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		grep -q 'brew shellenv' "$$HOME/.zprofile" 2>/dev/null || \
			echo 'eval "$$($(BREW_BIN_PATH)/brew shellenv)"' >> "$$HOME/.zprofile"; \
	fi

brewfile: homebrew ## Install packages listed in Brewfile
	if [ ! -f $(BOOTSTRAP_DIR)/homebrew/Brewfile.base ]; then \
		echo "⚠️ Base Brewfile not found. Skipping package installation."; \
	else \
		echo "📦 Installing Homebrew packages from Brewfile..."; \
		$(BREW_BIN_PATH)/brew bundle --file=$(BOOTSTRAP_DIR)/homebrew/Brewfile.base; \
	fi

python: homebrew ## Install Python
	if [ ! -x $(BREW_BIN_PATH)/uv ]; then \
		echo "📦 Installing uv..."; \
		$(BREW_BIN_PATH)/brew install uv; \
	fi
	echo "🐍 Installing Python with uv..."
	$(BREW_BIN_PATH)/uv python install --default --preview

fonts: homebrew ## Install fonts
	if [ ! -x $(BREW_BIN_PATH)/age ]; then \
		echo "📦 Installing age..."; \
		$(BREW_BIN_PATH)/brew install age; \
	fi
	FONTS_DIR="$$HOME/Library/Fonts"; \
	mkdir -p "$$FONTS_DIR"; \
	find $(BOOTSTRAP_DIR)/fonts -type f -name '*.age' | while IFS= read -r f; do \
		name=$$(basename "$$f" .age); \
		echo "🔐 Decrypting $$name"; \
		$(BREW_BIN_PATH)/age --decrypt "$$f" > "$$FONTS_DIR/$$name"; \
	done

claude-code: homebrew ## Install Claude Code and set up config
	if ! $(BREW_BIN_PATH)/brew list --cask claude-code >/dev/null 2>&1; then \
		echo "📦 Installing Claude Code..."; \
		$(BREW_BIN_PATH)/brew install --cask claude-code; \
	else \
		echo "📦 Claude Code is already installed."; \
	fi
	CLAUDE_DIR="$$HOME/.claude"; \
	REPO_DIR="$$(pwd)/$(BOOTSTRAP_DIR)/claude-code"; \
	mkdir -p "$$CLAUDE_DIR"; \
	for file in settings.json CLAUDE.md keybindings.json; do \
		src="$$REPO_DIR/$$file"; \
		dest="$$CLAUDE_DIR/$$file"; \
		if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
			echo "🔗 $$file already linked."; \
		elif [ -L "$$dest" ] || [ -e "$$dest" ]; then \
			echo "📋 Backing up existing $$file to $$file.backup"; \
			mv "$$dest" "$$dest.backup"; \
			ln -s "$$src" "$$dest"; \
			echo "🔗 Linked $$file"; \
		else \
			ln -s "$$src" "$$dest"; \
			echo "🔗 Linked $$file"; \
		fi; \
	done
	echo "🔌 Setting up Claude Code plugins..."
	claude plugin marketplace list 2>/dev/null | grep -q "claude-plugins-official" || \
		claude plugin marketplace add anthropics/claude-plugins-official --scope user
	claude plugin marketplace list 2>/dev/null | grep -q "astral-sh" || \
		claude plugin marketplace add astral-sh/claude-code-plugins --scope user
	claude plugin list 2>/dev/null | grep -q "gopls-lsp@claude-plugins-official" || \
		claude plugin install gopls-lsp@claude-plugins-official --scope user
	claude plugin list 2>/dev/null | grep -q "astral@astral-sh" || \
		claude plugin install astral@astral-sh --scope user
	echo "✅ Claude Code setup complete."

iterm2: homebrew ## Install iTerm2 and import settings
	if ! $(BREW_BIN_PATH)/brew list --cask iterm2 >/dev/null 2>&1; then \
		echo "📦 Installing iTerm2..."; \
		$(BREW_BIN_PATH)/brew install --cask iterm2; \
	else \
		echo "📦 iTerm2 is already installed."; \
	fi
	echo "⚙️ Importing iTerm2 settings..."
	defaults import com.googlecode.iterm2 $(BOOTSTRAP_DIR)/iterm2/com.googlecode.iterm2.plist
	defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$$(pwd)/$(BOOTSTRAP_DIR)/iterm2"
	defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	echo "✅ iTerm2 settings imported. Restart iTerm2 to apply."
