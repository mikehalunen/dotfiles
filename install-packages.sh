#!/bin/sh

# This is a script to set up an OS X laptop for web development.
# It can be run multiple times on the same machine safely. It
# installs, upgrades, or skips packages based on what is already
# installed on the machine.

# This script installs the following packages

# - Homebrew for managing operating system libraries
# - Node.js and NPM, for running apps and installing JavaScript packages
# - Yo, Bower and Grunt for working on Starterkit-based projects

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      echo "Upgrading %s ..." "$1"
      brew upgrade "$@"
    else
      echo "Already using the latest version of %s. Skipping ..." "$1"
    fi
  else
    echo "Installing %s ..." "$1"
    brew install "$@"
  fi
}

brew_is_installed() {
  local name="$(brew_expand_alias "$1")"

  brew list -1 | grep -Fqx "$name"
}

brew_is_upgradable() {
  local name="$(brew_expand_alias "$1")"

  ! brew outdated --quiet "$name" >/dev/null
}

brew_tap() {
  brew tap "$1" 2> /dev/null
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_launchctl_restart() {
  local name="$(brew_expand_alias "$1")"
  local domain="homebrew.mxcl.$name"
  local plist="$domain.plist"

  echo "Restarting %s ..." "$1"
  mkdir -p "$HOME/Library/LaunchAgents"
  ln -sfv "/usr/local/opt/$name/$plist" "$HOME/Library/LaunchAgents"

  if launchctl list | grep -Fq "$domain"; then
    launchctl unload "$HOME/Library/LaunchAgents/$plist" >/dev/null
  fi
  launchctl load "$HOME/Library/LaunchAgents/$plist" >/dev/null
}

if ! command -v brew >/dev/null; then
  echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    export PATH="/usr/local/bin:$PATH"
else
  echo "Homebrew already installed. Skipping ..."
fi

echo "Updating Homebrew formulas ..."
brew update


# http://github.com/sindresorhus/quick-look-plugins
  echo 'Installing Quick Look plugins...'
  brew tap phinze/homebrew-cask
  brew install brew-cask
  brew cask install suspicious-package quicklook-json qlmarkdown qlstephen qlcolorcode

  brew tap caskroom/versions
  brew cask install sublime-text3

  brew cask install iterm2

# brew_install_or_upgrade 'git'

echo "Installing Node"
brew_install_or_upgrade 'node'

echo "Installing Yo"
npm install -g yo

echo "Installing Bower"
npm install -g bower

echo "Installing Grunt"
npm install -g grunt-cli

if [ -f "$HOME/.brewinstall.local" ]; then
  . "$HOME/.brewinstall.local"
fi
