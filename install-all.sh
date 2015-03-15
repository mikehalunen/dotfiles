#!/usr/bin/env zsh

# A simple script for setting up OSX dev environment.

dev="$HOME/Developer/dotfiles"

pushd .
# mkdir -p $dev
cd $dev

echo 'Tweaking OS X...'
  source 'etc/osx.sh'

echo 'Installing Brew and packages...'
  source 'brew-installs.sh'

echo 'Symlinking config files...'
  source 'symlink-dotfiles.sh'

echo 'Applying sublime config...'
  source 'sublime/setup-sublime.sh'

 echo 'Applying terminal config...'
  source 'terminal/setup-terminal.sh'


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
