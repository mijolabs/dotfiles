#!/usr/bin/env zsh

HOMEBREW_PACKAGES_FILENAME="packages.brew"


# Install Xcode command line developer tools
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
    echo "[+] Installing Xcode command line developer tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress     # For softwareupdate to list Command Line Tools
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose;
else
    echo "[+] Xcode command line developer already installed."
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
    echo "[!] No Homebrew packages to install."
else
    echo "[+] Installing Homebrew packages: ${HOMEBREW_PACKAGE_LIST[*]}"
    await_installation_completion
    brew install ${HOMEBREW_PACKAGE_LIST[*]}
fi
