.PHONY: help all _sudo-upfront macos xcode-clt homebrew omz brewfile python fonts claude-code ghostty iterm2
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

all: _sudo-upfront macos xcode-clt homebrew omz brewfile python claude-code ghostty ## Run all base setup tasks 🚀
	echo "✅ All installations complete!"


_sudo-upfront:
	if [ "$(MAKECMDGOALS)" != "all" ]; then \
		echo "❌ Only for use in 'make all'."; \
		exit 1; \
	fi
	echo "🔑 Requesting sudo upfront..."
	sudo -v
	while true; do sudo -n true; sleep 50; kill -0 "$$PPID" || exit; done 2>/dev/null &

macos: ## Apply macOS system config
	echo "⚙️ Applying macOS system config..."
	chmod +x $(BOOTSTRAP_DIR)/macos/macos-bootstrap.sh && sudo $(BOOTSTRAP_DIR)/macos/macos-bootstrap.sh

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
		if [ -z "$$PROD" ]; then \
			echo "❌ Could not find Command Line Tools package in softwareupdate catalog."; \
			rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
			exit 1; \
		fi; \
		sudo softwareupdate -i "$$PROD" --verbose; \
		rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; \
	fi

homebrew: xcode-clt ## Install Homebrew
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

omz: xcode-clt ## Install oh-my-zsh and configure shell
	if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "💻 Installing oh-my-zsh..."; \
		RUNZSH=no CHSH=no sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
		[ -f "$$HOME/.zshrc" ] && mv "$$HOME/.zshrc" "$$HOME/.zshrc.omz-default"; \
	else \
		echo "💻 oh-my-zsh is already installed."; \
	fi
	echo "🔗 Linking custom zsh files..."
	for f in $$(pwd)/$(BOOTSTRAP_DIR)/omz/custom/*.zsh; do \
		name=$$(basename "$$f"); \
		dest="$$HOME/.oh-my-zsh/custom/$$name"; \
		if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$f" ]; then \
			echo "  🔗 $$name already linked."; \
		else \
			ln -sf "$$f" "$$dest"; \
			echo "  🔗 Linked $$name"; \
		fi; \
	done
	ZSHRC_SOURCE="source $$(pwd)/$(BOOTSTRAP_DIR)/omz/zshrc.sh"; \
	sed -i.bak '\|source .*/$(BOOTSTRAP_DIR)/.*/zshrc\.sh|d' "$$HOME/.zshrc" 2>/dev/null || true; \
	rm -f "$$HOME/.zshrc.bak"; \
	sed -i.bak '\|source .*oh-my-zsh\.sh|d' "$$HOME/.zshrc" 2>/dev/null || true; \
	rm -f "$$HOME/.zshrc.bak"; \
	if grep -qF "$$ZSHRC_SOURCE" "$$HOME/.zshrc" 2>/dev/null; then \
		echo "  🔗 .zshrc already linked."; \
	else \
		echo "$$ZSHRC_SOURCE" >> "$$HOME/.zshrc"; \
		echo "  🔗 Linked .zshrc"; \
	fi
	ZPROFILE_SOURCE="source $$(pwd)/$(BOOTSTRAP_DIR)/omz/zprofile.sh"; \
	sed -i.bak '\|source .*/$(BOOTSTRAP_DIR)/.*/zprofile\.sh|d' "$$HOME/.zprofile" 2>/dev/null || true; \
	rm -f "$$HOME/.zprofile.bak"; \
	if grep -qF "$$ZPROFILE_SOURCE" "$$HOME/.zprofile" 2>/dev/null; then \
		echo "  🔗 .zprofile already linked."; \
	else \
		echo "$$ZPROFILE_SOURCE" >> "$$HOME/.zprofile"; \
		echo "  🔗 Linked .zprofile"; \
	fi
	echo "✅ Shell configured."

brewfile: homebrew ## Install packages listed in Brewfile
	if [ ! -f $(BOOTSTRAP_DIR)/homebrew/Brewfile.base ]; then \
		echo "⚠️ Base Brewfile not found. Skipping package installation."; \
	else \
		echo "📦 Installing Homebrew packages from Brewfile..."; \
		$(BREW_BIN_PATH)/brew bundle --file=$(BOOTSTRAP_DIR)/homebrew/Brewfile.base; \
	fi

python: homebrew ## Install Python via uv
	if [ ! -x $(BREW_BIN_PATH)/uv ]; then \
		echo "📦 Installing uv..."; \
		$(BREW_BIN_PATH)/brew install uv; \
	fi
	echo "🐍 Installing Python with uv..."
	$(BREW_BIN_PATH)/uv python install --default --preview

fonts: homebrew ## *Install fonts (interactive — requires passphrase)
	if [ ! -x $(BREW_BIN_PATH)/age ]; then \
		echo "📦 Installing age..."; \
		$(BREW_BIN_PATH)/brew install age; \
	fi
	FONTS_DIR="$$HOME/Library/Fonts"; \
	mkdir -p "$$FONTS_DIR"; \
	find $(BOOTSTRAP_DIR)/fonts -type f -name '*.age' | while IFS= read -r f; do \
		name=$$(basename "$$f" .age); \
		if [ -f "$$FONTS_DIR/$$name" ]; then \
			echo "  ✅ $$name already installed."; \
		else \
			echo "  🔐 Decrypting $$name"; \
			$(BREW_BIN_PATH)/age --decrypt "$$f" > "$$FONTS_DIR/$$name"; \
		fi; \
	done

claude-code: homebrew ## Install and bootstrap Claude Code
	if ! $(BREW_BIN_PATH)/brew list --cask claude-code >/dev/null 2>&1; then \
		echo "📦 Installing Claude Code..."; \
		$(BREW_BIN_PATH)/brew install --cask claude-code; \
	else \
		echo "📦 Claude Code is already installed."; \
	fi
	echo "🔗 Linking Claude Code config files..."
	CLAUDE_DIR="$$HOME/.claude"; \
	REPO_DIR="$$(pwd)/$(BOOTSTRAP_DIR)/claude-code/symlinks"; \
	mkdir -p "$$CLAUDE_DIR"; \
	for src in "$$REPO_DIR"/*; do \
		name=$$(basename "$$src"); \
		dest="$$CLAUDE_DIR/$$name"; \
		if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
			echo "  🔗 $$name already linked."; \
		elif [ -L "$$dest" ] || [ -e "$$dest" ]; then \
			echo "  📋 Backing up existing $$name to $$name.backup"; \
			mv "$$dest" "$$dest.backup"; \
			ln -s "$$src" "$$dest"; \
			echo "  🔗 Linked $$name"; \
		else \
			ln -s "$$src" "$$dest"; \
			echo "  🔗 Linked $$name"; \
		fi; \
	done
	echo "🔌 Setting up Claude Code plugins..."
	SETTINGS="$$(pwd)/$(BOOTSTRAP_DIR)/claude-code/symlinks/settings.json"; \
	for entry in $$(jq -r '.extraKnownMarketplaces // {} | to_entries[] | "\(.key)=\(.value.source.repo)"' "$$SETTINGS"); do \
		name="$${entry%%=*}"; \
		repo="$${entry#*=}"; \
		if claude plugin marketplace list 2>/dev/null | grep -q "$$name"; then \
			echo "  🔌 $$name marketplace already registered."; \
		else \
			echo "  🔌 Registering $$name marketplace"; \
			claude plugin marketplace add "$$repo" --scope user; \
		fi; \
	done; \
	for plugin in $$(jq -r '.enabledPlugins // {} | keys[]' "$$SETTINGS"); do \
		if claude plugin list 2>/dev/null | grep -q "$$plugin"; then \
			echo "  🔌 $$plugin already installed."; \
		else \
			echo "  🔌 Installing $$plugin"; \
			claude plugin install "$$plugin" --scope user; \
		fi; \
	done
	echo "✅ Claude Code setup complete."

ghostty: homebrew ## Install Ghostty and symlink config
	if ! $(BREW_BIN_PATH)/brew list --cask ghostty >/dev/null 2>&1; then \
		echo "👻 Installing Ghostty..."; \
		$(BREW_BIN_PATH)/brew install --cask ghostty; \
	else \
		echo "👻 Ghostty is already installed."; \
	fi
	echo "🔗 Linking Ghostty config..."
	GHOSTTY_DIR="$$HOME/Library/Application Support/com.mitchellh.ghostty"; \
	REPO_DIR="$$(pwd)/$(BOOTSTRAP_DIR)/ghostty"; \
	mkdir -p "$$GHOSTTY_DIR"; \
	for src in "$$REPO_DIR"/config.ghostty "$$REPO_DIR"/shaders; do \
		name=$$(basename "$$src"); \
		dest="$$GHOSTTY_DIR/$$name"; \
		if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
			echo "  🔗 $$name already linked."; \
		elif [ -L "$$dest" ] || [ -e "$$dest" ]; then \
			echo "  📋 Backing up existing $$name to $$name.backup"; \
			mv "$$dest" "$$dest.backup"; \
			ln -s "$$src" "$$dest"; \
			echo "  🔗 Linked $$name"; \
		else \
			ln -s "$$src" "$$dest"; \
			echo "  🔗 Linked $$name"; \
		fi; \
	done
	echo "✅ Ghostty setup complete."

iterm2: homebrew ## *Install iTerm2 and import settings
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
