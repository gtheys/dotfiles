#!/bin/sh

if test ! $(which rbenv)
then
  echo "  Installing rbenv for you."
  brew install rbenv > /tmp/rbenv-install.log
fi

if test ! $(which ruby-build)
then
  echo "  Installing ruby-build for you."
  brew install ruby-build > /tmp/ruby-build-install.log
  brew install rbenv-default-gems
  echo 'puppet' >> "$(brew --prefix rbenv)/default-gems"
  echo 'puppet-lint' >> "$(brew --prefix rbenv)/default-gems"
  echo 'bundler' >> "$(brew --prefix rbenv)/default-gems"
fi
