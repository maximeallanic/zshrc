#!/usr/bin/env sh

# Install packages
apt install autojump zsh command-not-found

# Antigen
curl -L git.io/antigen > /usr/local/share/antigen.zsh

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | XDG_CONFIG_HOME="/usr/local/share" bash
chmod -R 777 /usr/local/share/nvm

# Install Vimrc
rm -rf /etc/vimrc
ln -s `pwd`/vimrc /etc/vimrc

# Install Vim
rm -rf /etc/vim
ln -s `pwd`/vim /etc/vim

# Install Zshrc
rm -rf /etc/zsh/zshrc
ln -s `pwd`/zshrc /etc/zsh/zshrc

touch ~/.zshrc

# Install catfile
ln -s `pwd`/cat-file.sh /usr/local/bin/catfile

# Set Shell for Current User
for user in $(eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d: -f1)
do
    chsh --shell `which zsh` $user
done

# Initialize and Start new Shell
zsh
