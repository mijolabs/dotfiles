#!/usr/bin/env zsh

CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER")


# Enable Firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# Disable Bonjour Advertising Service. Doesn't affect AirDrop. Final Cut Studio and AirPort Base Station management may not operate properly.
sudo -u "$CURRENT_USER" defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

# Disable Power Nap & Wake for Network Access
pmset -a powernap 0
pmset -a womp 0

# Disable Siri
sudo -u "$CURRENT_USER" defaults write com.apple.Siri StatusMenuVisible -bool false
sudo -u "$CURRENT_USER" defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Show IP when clicking on clock on login page
# sudo -u "$CURRENT_USER" defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable creation of `.DS_Store` files on network drives and external disks
sudo -u "$CURRENT_USER" defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
sudo -u "$CURRENT_USER" defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show battery percentage
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Show bluetooth icon
sudo -u "$CURRENT_USER" defaults -currentHost write com.apple.controlcenter Bluetooth -int 18

# Enable the input menu in the menu bar
sudo -u "$CURRENT_USER" defaults write com.apple.TextInputMenu visible -bool true

# Expand print panel by default
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable recent apps in the Dock
launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" defaults write com.apple.dock show-recents -int 0

# Prevent Time Machine from prompting to use new hard drives as backup volume
sudo -u "$CURRENT_USER" defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Expand save panel by default
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Prevent Photos.app from opening when a device is plugged
sudo -u "$CURRENT_USER" defaults write com.apple.ImageCapture disableHotPlug -bool yes

# Finder preferences
# Finder: Visibility of hidden files
sudo -u "$CURRENT_USER" defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: Show filename extensions
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: Show status bar
sudo -u "$CURRENT_USER" defaults write com.apple.finder ShowStatusBar -bool true

# Finder: Full POSIX path as window title
sudo -u "$CURRENT_USER" defaults write com.apple.finder _FXShowPosixPathInTitle -bool false

# Finder: Path bar
sudo -u "$CURRENT_USER" defaults write com.apple.finder ShowPathbar -bool true

# Finder: New windows open $HOME
sudo -u "$CURRENT_USER" defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Disable the warning when changing a file extension
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: Text selection in Quick Look
sudo -u "$CURRENT_USER" defaults write com.apple.finder QLEnableTextSelection -bool true

# Finder: Default search scope
# This Mac       : `SCev`
# Current Folder : `SCcf`
# Previous Scope : `SCsp`
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" 

# Finder: Disable warning before emptying Trash
sudo -u "$CURRENT_USER" defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Finder: Keep folders on top when sorting by name
sudo -u "$CURRENT_USER" defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Finder: Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
sudo -u "$CURRENT_USER" defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist

# Set default directory to $HOME instead of iCloud documents in the fileviewer dialog when saving a new document
# "true" to default to iCloud, false to default to home directory
sudo -u "$CURRENT_USER" defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool false


# Restart services
killall cfprefsd
killall SystemUIServer
killall -HUP bluetoothd
killall ControlStrip
killall Finder
killall Dock
