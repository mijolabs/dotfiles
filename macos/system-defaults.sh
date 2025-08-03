#!/usr/bin/env zsh
set -euo pipefail

# Ensure script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "❌ Please run this script with sudo:"
  echo "   sudo $0"
  exit 1
fi

CURRENT_USER="$(/usr/bin/stat -f %Su /dev/console)"
USER_ID="$(id -u "$CURRENT_USER")"
USER_HOME="$(dscl . -read /Users/$CURRENT_USER NFSHomeDirectory | awk '{print $2}')"

echo "🛠️  Configuring macOS settings for user: $CURRENT_USER"
echo

# --- Firewall ---
echo "🧱 Enabling Firewall and Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# --- Bonjour / Multicast ---
echo "📡 Disabling Bonjour Advertising..."
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

# --- Power Management ---
echo "🔌 Disabling Power Nap and Wake-on-LAN..."
pmset -a powernap 0
pmset -a womp 0

# --- Siri ---
echo "🧏 Disabling Siri..."
sudo -u "$CURRENT_USER" defaults write com.apple.Siri StatusMenuVisible -bool false
sudo -u "$CURRENT_USER" defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# --- .DS_Store behavior ---
echo "🗂️ Disabling .DS_Store creation on network/USB volumes..."
sudo -u "$CURRENT_USER" defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- UI Tweaks ---
echo "🔋 Showing battery percentage..."
sudo -u "$CURRENT_USER" defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

echo "🟦 Showing Bluetooth icon..."
sudo -u "$CURRENT_USER" defaults -currentHost write com.apple.controlcenter Bluetooth -int 18

echo "🌐 Enabling Input Menu..."
sudo -u "$CURRENT_USER" defaults write com.apple.TextInputMenu visible -bool true

# --- Print & Save Panels ---
echo "🖨️ Expanding print/save panels by default..."
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# --- Photos.app ---
echo "📸 Preventing Photos from launching on device connect..."
sudo -u "$CURRENT_USER" defaults write com.apple.ImageCapture disableHotPlug -bool true

# --- Time Machine ---
echo "⏱️ Preventing Time Machine prompts on new disks..."
sudo -u "$CURRENT_USER" defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# --- Finder ---
echo "🧭 Configuring Finder preferences..."
sudo -u "$CURRENT_USER" defaults write com.apple.finder AppleShowAllFiles -bool true
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain AppleShowAllExtensions -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.finder ShowStatusBar -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.finder ShowPathbar -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
sudo -u "$CURRENT_USER" defaults write com.apple.finder QLEnableTextSelection -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.finder WarnOnEmptyTrash -bool false
sudo -u "$CURRENT_USER" defaults write com.apple.finder _FXSortFoldersFirst -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.finder _FXShowPosixPathInTitle -bool false
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
sudo -u "$CURRENT_USER" defaults write com.apple.finder NewWindowTarget -string "PfHm"
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

# --- Save to disk instead of iCloud by default ---
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# --- Finder icon grid alignment ---
echo "🔳 Setting icon grid alignment in Finder views..."
PLIST="$USER_HOME/Library/Preferences/com.apple.finder.plist"
if [[ -f "$PLIST" ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" "$PLIST" || true
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy kind" "$PLIST" || true
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" "$PLIST" || true
fi

# --- Disable recent apps in Dock ---
echo "🧼 Disabling recent apps in Dock..."
launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" defaults write com.apple.dock show-recents -int 0

# --- Restart Services ---
echo "♻️ Restarting affected services..."
for service in cfprefsd SystemUIServer bluetoothd ControlStrip Finder Dock; do
  killall "$service" &>/dev/null || true
done

echo "✅ macOS configuration completed for user: $CURRENT_USER"
