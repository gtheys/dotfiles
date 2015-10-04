#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Install homebrew packages
brew install grc coreutils spark

# This how I Install vim (need xcode installed)
brew install macvim --with-cscope --with-lua --override-system-vim --with-luajit --with-python3
brew linkapps macvim

# Needed for my :Ag search in Vim
brew install the_silver_searcher

brew install virtualbox
brew install vagrant
brew install ansible
brew install terraform
brew install packer

# Install brew cask
brew install caskroom/cask/brew-cask

brew cask install --appdir="/Applications" airmail
brew cask install --appdir="/Applications" skype
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" skitch
brew cask install --appdir="/Applications" google-chrome

exit 0
