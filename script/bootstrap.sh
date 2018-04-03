#!/usr/bin/env bash
#
# bootstrap installs things.

DOTFILES_ROOT="`pwd`"

# Test whether a command exists
# $1 - cmd to test
type_exists() {
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}

echo ''
echo 'Bootstrapping local environment'
echo ''

# Inialize submodule(s)"
echo "Initializing submodule(s)"
git submodule update --init --recursive

source install/link.sh

# Before relying on Homebrew, check that packages can be compiled
if ! type_exists 'gcc'; then
    echo "The XCode Command Line Tools must be installed first."
    echo "Run in a terminal gcc and follow instructions for installation"
    echo "Then run: bash ~/.dotfiles/script/bootstrap"
    exit 1
fi

# Check for Homebrew
if ! type_exists 'brew'; then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
fi

# Check if git comes from Homebrew and install if needed
if brew list | grep --quiet git; then
  echo "Homebrew version of git already installed!"
else
  echo "Updating Homebrew..."
  brew update
  echo "Installing Git..."
  brew install git
  echo "New git version will be used after you close the terminal :("
fi

# run brew bundle and install most of our tools
echo "Updating Homebrew..."
brew bundle

# Install App store application
source $DOTFILES_ROOT/script/mas.sh

# After the install, setup fzf
echo "\\n\\nRunning fzf install script..."
/usr/local/opt/fzf/install --all --no-bash --no-fish

# after hte install, install neovim python libraries
echo -e "\\n\\nRunning Neovim Python install"
pip2 install --user neovim
pip3 install --user neovim

# Check If I need to fetch this submodule
# Use this for my colorschemes
if [ -d $DOTFILES_ROOT/.config/base16-shell ]; then
  git submodule update --recursive --quiet
  echo "Update Base16 colorscheme"
else
  git submodule update --recursive --init --quiet
  echo "Initialized base 16 colorscheme"
fi

# Install App store application
source $DOTFILES_ROOT/script/vscode.sh

# Switch to Oh My SZH
echo "Install Oh my ZSH"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo ''
echo 'All installed!'
