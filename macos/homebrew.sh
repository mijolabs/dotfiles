#!/usr/bin/env zsh
set -euo pipefail

# ------------------------------
# Install Xcode Command Line Tools
# ------------------------------
echo "🔍 Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    PACKAGE_NAME=$(softwareupdate -l 2>/dev/null \
        | awk -F ': ' '/Label: Command Line Tools for Xcode/ {print $2}' \
        | sort -u | tail -n1)

    if [[ -n "$PACKAGE_NAME" ]]; then
        echo "📥 Installing package: $PACKAGE_NAME"
        softwareupdate -i "$PACKAGE_NAME" --verbose
        echo "✅ Xcode Command Line Tools installed successfully."
    else
        echo "❌ Could not find the Command Line Tools package label."
        exit 1
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
else
    echo "✅ Xcode Command Line Tools already installed."
fi


# --------------
# Install Homebrew
# --------------
echo "🔍 Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
    echo "✅ Homebrew installed successfully."
else
    echo "✅ Homebrew already installed."
fi


# -----------------------
# Install Homebrew packages
# -----------------------
BREWFILE_PATH="homebrew/Brewfile"
if [[ -f "$BREWFILE_PATH" ]]; then
  echo "📦 Installing packages from $BREWFILE_PATH..."
  brew bundle --file="$BREWFILE_PATH"
  echo "✅ Brew bundle complete."
else
  echo "⚠️  No Brewfile found at $BREWFILE_PATH"
fi
