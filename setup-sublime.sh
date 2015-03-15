#!/usr/bin/env zsh

dev="$HOME/Developer/dotfiles"
pushd .
cd $dev


  st=$(pwd)/sublime/Packages

  as="$HOME/Library/Application Support/Sublime Text 3/Packages"
  asprefs="$as/User/Preferences.sublime-settings"

  echo "Applying sublime config from $st to $as"

  echo 'Applying themes'
  if [[ -d "$as" ]]; then

    for theme in $st/*Theme*; do
      cp -r $theme $as
    done
    echo $asprefs
    rm $asprefs
    echo 'Applying user preferences'
    cp -r "$st/User/Preferences.sublime-settings" "$as/User/"


  else
    echo "Install Sublime Text http://www.sublimetext.com"
  fi
echo 'sublime config complete'
popd
