#!/usr/bin/env zsh

HOMEBREW_PACKAGES_FILENAME="packages.brew"


# Install Xcode command line tools
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
    echo "[+] Installing Xcode command line developer tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress     # For softwareupdate to list Command Line Tools
    PACKAGE_NAME=$(softwareupdate -l |  awk -F ': ' '/Label: Command Line Tools for Xcode/ {print $2}')
    softwareupdate -i "$PACKAGE_NAME" --verbose
else
    echo "[*] Xcode command line developer already installed."
fi


# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# Install Homebrew packages
HOMEBREW_PACKAGE_LIST=()
while IFS= read -r package; do
    package=$(echo "$package" | xargs)      # Trim any whitespace around package name
    if [[ ! $package =~ ^\s*# ]]; then      # Only include line if it hasn't been commented out
        HOMEBREW_PACKAGE_LIST+=("$package")
    fi
done < "$HOMEBREW_PACKAGES_FILENAME"

if [ ${#HOMEBREW_PACKAGE_LIST[@]} -eq 0 ]; then
    echo "[!] No Homebrew packages to install in file: $HOMEBREW_PACKAGES_FILENAME"
else
    echo "[+] Installing Homebrew packages: ${HOMEBREW_PACKAGE_LIST[*]}"
    brew install ${HOMEBREW_PACKAGE_LIST[*]}
fi
