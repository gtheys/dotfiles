#!/usr/bin/env bash
#
# bootstrap installs things.

DOTFILES_ROOT="`pwd`"

source $DOTFILES_ROOT/lib/utils

echo ''
echo 'Bootstrapping local environment'
echo ''

# Before relying on Homebrew, check that packages can be compiled
if ! type_exists 'gcc'; then
    e_error "The XCode Command Line Tools must be installed first."
    e_info "  Run in a terminal gcc and follow instructions for installation"
    e_info "  Then run: bash ~/.dotfiles/script/bootstrap"
    exit 1
fi

# Check for Homebrew
if ! type_exists 'brew'; then
    e_info "Installing Homebrew..."
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
fi

# Check if git comes from Homebrew and install if needed
if brew list | grep --quiet git; then
  e_info "Homebrew version of git already installed!"
else
  e_info "Updating Homebrew..."
  brew update
  e_info "Installing Git..."
  brew install git
  e_user "New git version will be used after you close the terminal :("
fi

# run brew bundle and install most of our tools
e_info "Updating Homebrew..."
#brew bundle

# Install App store application
source $DOTFILES_ROOT/script/mas.sh

# After the install, setup fzf
e_info "\\n\\nRunning fzf install script..."
/usr/local/opt/fzf/install --all --no-bash --no-fish

# after hte install, install neovim python libraries
e_info -e "\\n\\nRunning Neovim Python install"
pip2 install --user neovim
pip3 install --user neovim

# Check If I need to fetch this submodule
# Use this for my colorschemes
if [ -d $DOTFILES_ROOT/.config/base16-shell ]; then
  git submodule update --recursive --quiet
  e_info "Update Base16 colorscheme"
else
  git submodule update --recursive --init --quiet
  e_success "Initialized base 16 colorscheme"
fi

# Install App store application
source $DOTFILES_ROOT/script/vscode.sh

# Switch to Oh My SZH
e_info "Install Oh my ZSH"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo ''
echo 'All installed!'
