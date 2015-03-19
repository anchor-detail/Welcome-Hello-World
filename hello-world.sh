#!/bin/sh

# https://github.com/mathiasbynens/dotfiles/blob/master/.osx

# Set the colours you can use
black='\033[0;30m'
white='\033[0;37m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# Set continue to false by default
CONTINUE=false

echo ""
cecho "###############################################" $red
cecho "#        DO NOT RUN THIS SCRIPT BLINDLY       #" $red
cecho "#         YOU'LL PROBABLY REGRET IT...        #" $red
cecho "#                                             #" $red
cecho "#              READ IT THOROUGHLY             #" $red
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" $red
cecho "###############################################" $red
echo ""

echo Install all AppStore Apps at first!
# no solution to automate AppStore installs
read -p "Press any key to continue... " -n1 -s
echo  '\n'

echo ""
cecho "###############################################" $red
cecho "#              BEGIN AUTOMATION               #" $red
cecho "#                                             #" $red
cecho "#         ENTER ADMINISTRATOR PASSWORD        #" $red
cecho "#      KEEP IT ALIVE UNTIL SCRIPT IS DONE     #" $red
cecho "###############################################" $red
echo ""

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###############################################################################
# General UI/UX
###############################################################################

echo ""
echo "SET COMPUTER NAME"
read COMPUTER_NAME
sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $COMPUTER_NAME
sudo scutil --set LocalHostName $COMPUTER_NAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME

echo ""
echo "HIDE THE TIME MACHINE, VOLUME, USER AND BLUETOOTH ICONS"

# Get the system Hardware UUID and use it for the next menubar stuff
  for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu"
  done

  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"

echo ""
echo "TURNING OFF THE SPOTLIGHT"

sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
echo 'Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.'
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

echo ""
echo "CHANGE INDEXING ORDER AND DISABLE SOME SEARCH RESULTS IN SPOTLIGHT"

  # Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
  #   MENU_DEFINITION
  #   MENU_CONVERSION
  #   MENU_EXPRESSION
  #   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
  #   MENU_WEBSEARCH             (send search queries to Apple)
  #   MENU_OTHER
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
  # Load new settings before rebuilding the index
  killall mds > /dev/null 2>&1
  # Make sure indexing is enabled for the main volume
  sudo mdutil -i on / > /dev/null
  # Rebuild the index from scratch
  sudo mdutil -E / > /dev/null

echo ""
echo "EXPANDING THE SAVE PANEL"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo ""
echo "AUTOMATICALLY QUIT THE PRINTER APP ONCE THE PRINT JOB IS COMPLETE"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
echo ""
echo "Displaying ASCII control characters using caret notation in standard text views"
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

echo ""
echo "SAVING TO DISK INSTEAD OF ICLOUD BY DEFAULT"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo ""
echo "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo ""
echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
echo "Removing duplicates in the 'Open With' menu"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo ""
echo "DISABLE SMART QUOTES AND DASHES"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo ""
echo "TOGGLE BETWEEN LIGHT AND DARK MODE ctrl+opt+cmd+t"
# http://www.reddit.com/r/apple/comments/2jr6s2/1010_i_found_a_way_to_dynamically_switch_between/
  sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true

###############################################################################
# General Power and Performance modifications
###############################################################################

echo ""
echo "Disable hibernation"
  sudo pmset -a hibernatemode 0
  sudo rm /var/vm/sleepimage

echo ""
echo "Disable the sudden motion sensor"
  sudo pmset -a sms 0


echo ""
echo "Disable system-wide resume"
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

echo ""
echo "Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400


################################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

echo ""
echo "Increasing sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo ""
echo "Enabling full keyboard access for all controls"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo ""
echo "Disabling press-and-hold for special keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo ""
echo "Setting a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 0

echo ""
echo "Disable auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo ""
echo "Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

echo ""
echo "Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300

echo ""
echo "Disable display from automatically adjusting brightness? (y/n)"
  sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

echo "Tap to click"
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1



###############################################################################
# Screen
###############################################################################

echo ""
echo "Requiring password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 15

echo ""
echo "SCREENSHOT LOCATION"
  screenshot_location="${HOME}/Screen-Capture"
defaults write com.apple.screencapture location -string "${screenshot_location}"

echo ""
echo "Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo ""
echo "Enabling HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder
###############################################################################

echo ""
echo "Show icons for hard drives, servers, and removable media on the desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

echo ""
echo "Show hidden files in Finder by default? (y/n)"
#  defaults write com.apple.Finder AppleShowAllFiles -bool true

echo ""
echo "Show dotfiles in Finder by default"
#  defaults write com.apple.finder AppleShowAllFiles TRUE

echo ""
echo "Show all filename extensions in Finder by default? (y/n)"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  
echo ""
echo "Show status bar in Finder by default? (y/n)"
  defaults write com.apple.finder ShowStatusBar -bool true

echo ""
echo "Display full POSIX path as Finder window title"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo ""
echo "Disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo ""
echo "Use column view in all Finder windows by default?"
  defaults write com.apple.finder FXPreferredViewStyle Clmv

echo ""
echo "Avoid creation of .DS_Store files on network volumes?"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo ""
echo "Allowing text selection in Quick Look/Preview in Finder by default"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo ""
echo "Show item info near icons on the desktop and in other icon views? (y/n)"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

echo ""
echo "Show item info to the right of the icons on the desktop? (y/n)"
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

echo ""
echo "Enable snap-to-grid for icons on the desktop and in other icon views? (y/n)"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist


###############################################################################
# Dock & Mission Control
###############################################################################


echo "Wipe all (default) app icons from the Dock? (y/n)"
  defaults write com.apple.dock persistent-apps -array

echo ""
echo "Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

echo ""
echo "Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

echo ""
echo "Set Dock to auto-hide and remove the auto-hiding delay? (y/n)"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0

###############################################################################
# Chrome, Safari, & WebKit
###############################################################################

echo ""
echo "Privacy: Don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo ""
echo "Hiding Safari's bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo ""
echo "Hiding Safari's sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo ""
echo "Disabling Safari's thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

echo ""
echo "Enabling Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo ""
echo "Making Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo ""
echo "Removing useless icons from Safari's bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

echo ""
echo "Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo ""
echo "Adding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo ""
echo "Disabling the annoying backswipe in Chrome"
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

echo ""
echo "Using the system-native print preview dialog in Chrome"
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true


###############################################################################
# Mail
###############################################################################

echo ""
echo "Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false


###############################################################################
# Terminal
###############################################################################

echo ""
echo "Enabling UTF-8 ONLY in Terminal.app and setting the Homebrew theme by default"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Homebrew"
defaults write com.apple.Terminal "Startup Window Settings" -string "Homebrew"


###############################################################################
# Time Machine
###############################################################################

echo ""
echo "Prevent Time Machine from prompting to use new hard drives as backup volume? (y/n)"
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo ""
echo "Disable local Time Machine backups? (This can take up a ton of SSD space on <128GB SSDs) (y/n)"
  hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Messages                                                                    #
###############################################################################

echo ""
echo "Disable smart quotes in Messages.app? (it's annoying for messages that contain code) (y/n)"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

echo ""
echo "Disable continuous spell checking in Messages.app? (y/n)"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false


###############################################################################
# Transmission.app                                                            #
###############################################################################

  echo "TRANSMISSION"
  echo "Setting up an incomplete downloads folder in Downloads"
  mkdir -p ~/Transmission/Incomplete
  defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

  echo ""
  echo "Don't prompt for confirmation before downloading"
  defaults write org.m0k.transmission DownloadAsk -bool false

  echo ""
  echo "Trash original torrent files"
  defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

  echo ""
  echo "Hide the donate message"
  defaults write org.m0k.transmission WarningDonate -bool false

  echo ""
  echo "Hide the legal disclaimer"
  defaults write org.m0k.transmission WarningLegal -bool false


###############################################################################
# Kill affected applications
###############################################################################

echo ""
cecho "Done!" $cyan
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
cecho "Killing some open applications in order to take effect." $red
echo ""

read -p "Press any key to continue... " -n1 -s
echo  '\n'

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
  "Terminal" "Transmission"; do
  killall "${app}" > /dev/null 2>&1
done
