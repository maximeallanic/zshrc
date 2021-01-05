#!/usr/bin/env sh

# Zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

# Install Vimrc
rm -rf ~/.vimrc
ln -s `pwd`/vimrc ~/.vimrc

# Install Vim
rm -rf ~/.vim
ln -s `pwd`/vim ~/.vim
# Install Zshrc
rm -rf ~/.zshrc
ln -s `pwd`/zshrc ~/.zshrc

# Install Profile
rm -rf ~/.profile
ln -s `pwd`/profile ~/.profile

# Set Shell for Current User
chsh --shell `which zsh` $USER

# Initialize and Start new Shell
zsh
