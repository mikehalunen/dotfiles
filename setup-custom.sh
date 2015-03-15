#!/usr/bin/env zsh

# A simple script for setting up OSX dev environment.

dev="$HOME/Developer/dotfiles"
# pushd .
# mkdir -p $dev
cd $dev

# If we on OS X, and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then

  echo 'Tweaking OS X...'
  #source 'etc/osx.sh'

  # http://github.com/sindresorhus/quick-look-plugins
  echo 'Installing Quick Look plugins...'
    brew tap phinze/homebrew-cask
    brew install brew-cask
    brew cask install suspicious-package quicklook-json qlmarkdown qlstephen qlcolorcode
fi

echo 'Symlinking config files...'
  source 'symlink-dotfiles.sh'

echo 'Applying sublime config...'
  source 'setup-sublime.sh'



open_apps() {
  echo 'Install apps:'
  echo 'iterm:'
  open http://iterm2.com/
  echo 'Dropbox:'
  open https://www.dropbox.com
  echo 'Chrome:'
  open https://www.google.com/intl/en/chrome/browser/

}

echo 'Should I give you links for system applications (e.g. Skype, Chrome, )?'
echo 'n / y'
# read give_links
[[ "$give_links" == 'y' ]] && open_apps

popd
