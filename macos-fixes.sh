#!/usr/bin/env zsh

# Disable creation of `.DS_Store` files on network drives and external disks
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

