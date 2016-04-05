#!/bin/sh

# The purpose of this installer is to install the ChefDK package (if not already installed)
# and to kick off the cloning / customization of this repository.  The main point of customizing
# is to set the "build_user" and "home" JSON data values to the current user.

# NOTE: Requires git to be installed

# echo $'\342\230\225'

APPSTOREUSER=""
USERHOME=""
USERPASS=""
USERREPOPATH=""
DEFAULT_USERHOME="$HOME"
DEFAULT_USERNAME="$USER"
DEFAULT_USERREPOPATH="$DEFAULT_USERHOME/repositories/"
BASEURLHOST="gitlab.digitas.com"
REPO_NAME="osx-workstation"
REPO_PATH="/starter-kit/$REPO_NAME.git"

# test for required software
git --help >/dev/null
if [ "$?" != "0" ]; then
    echo "Please ensure git (via xcode) is installed"
    exit 1;
fi

echo "----------------------------------"
echo -n $'\342\230\225'
echo -n " OSX workstation install script "
echo $'\342\230\225'
echo "----------------------------------"
echo "Press ENTER to accept (defaults)"
# get/set username
read -p "Your LL username ($DEFAULT_USERNAME): " USERNAME
if [ "$USERNAME" == "" ]; then
    USERNAME=$DEFAULT_USERNAME
fi
# get/set password
read -s -p "Your LL password: " USERPASS
echo;
if [ "$USERPASS" == "" ]; then
    echo "No password specified.  Exiting."
    exit 1;
fi
# test password/sudo access
echo $USERPASS | sudo -kSp '' whoami > /dev/null
if [ "$?" != "0" ]; then
    echo "Was your password correct or do you have sudo rights to your machine?"
    exit 1;
fi
# get/set app store username
read -p "Your Apple App Store username (leave blank to skip): " APPSTOREUSER
# Confirm home directory
read -p "Home directory ($DEFAULT_USERHOME):" USERHOME
if [ "$USERHOME" == "" ]; then
    USERHOME=$DEFAULT_USERHOME
fi
# Confirm path to repositories
read -p "Repository path ($DEFAULT_USERREPOPATH):" USERREPOPATH
if [ "$USERREPOPATH" == "" ]; then
    USERREPOPATH=$DEFAULT_USERREPOPATH
fi

################################################
# get the osx-workstation repo
if [ -d "$USERREPOPATH/$REPO_NAME" ]; then
    cd $USERREPOPATH/$REPO_NAME
    # blow away local changes to ensure we get the latest
    git checkout .
    git pull
else
    # move to the correct directory
    mkdir -p $USERREPOPATH
    cd $USERREPOPATH

    # clone the repo
    echo "now attempting to clone git repo to `pwd`"
    git clone "https://$USERNAME:$USERPASS@$BASEURLHOST$REPO_PATH" | sh
    cd $REPO_NAME
fi

# install brew if necessary
if ! command -v brew >/dev/null; then
  echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    export PATH="/usr/local/bin:$PATH"
else
  echo "Homebrew already installed. Skipping ..."
fi

# install chefdk
if ! command -v chef-client >/dev/null; then
    echo "Installing ChefDK ..."
    brew tap caskroom/cask
    brew cask install chefdk
fi

# make custom JSON files from sample files
for j in sample-*.json; do cp "$j" "${j/sample-/}"; done

# replace username and home dir with user's variables
sed -i.bak "s/\(\"build_user\": \"\).*\"/\1$USERNAME\"/" solo*.json
sed -i.bak "s/\(\"home\": \"\).*\"/\1${USERHOME//\//\\/}\"/" solo*.json
sed -i.bak "s/\(\"mac_app_store\": { \"username\": \"\).*\"/\1${APPSTOREUSER}\"/" solo*.json
rm *.json.bak

# assemble cookbooks for a chef-client run
berks vendor cookbooks
# kick off default chef run
echo "----------------------------------"
echo -n $'\342\230\225'
echo -n " About to start Chef run.  Please wait ... "
echo $'\342\230\225'
echo $USERPASS | sudo -Sp '' chef-client -z -c solo.rb -j solo.json

if [ "$?" == "0" ]; then
    echo
    echo "This command installed the default set of applications:"
    echo "berks vendor cookbooks; sudo chef-client -z -c solo.rb -j solo.json"
    echo "The 'solo.json' can be replaced with other prepared json runlists,"
    echo "or you can make your own and share!"

    echo "----------------------------------"
    echo "Install complete. Have a nice day!"
    echo "----------------------------------"
fi
