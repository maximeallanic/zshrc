#!/usr/bin/env bash


BASE_DIR=$(dirname "$0")
USE_LINK="${USE_LINK:-NO}"

function copyOrLink () {
  rm -rf $2
  mkdir -p $(dirname "$2")
  if [[ "$USE_LINK" == "YES" ]]; then
    ln -s $1 $2
  else
    cp -rf $1 $2
  fi
}

apt update

# Install packages
apt install -y autojump zsh command-not-found

apt dist-upgrade -y

# Antigen
curl -L git.io/antigen > /usr/local/share/antigen.zsh

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | XDG_CONFIG_HOME="/usr/local/share" bash
chmod -R 777 /usr/local/share/nvm

# Install Vimrc
copyOrLink $BASE_DIR/vimrc /etc/vimrc

# Install Vim
copyOrLink $BASE_DIR/vim /etc/vim

# Install Zshrc
copyOrLink $BASE_DIR/zshrc /etc/zsh/zshrc
copyOrLink $BASE_DIR/zshrc /etc/zshrc

# Install catfile
copyOrLink $BASE_DIR/cat-file.sh /usr/local/bin/catfile

# Install antigen
rm -rf /usr/share/zsh-antigen
git clone https://github.com/zsh-users/antigen.git /usr/share/zsh-antigen


UID_MIN=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
UID_MAX=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)

touch /etc/zsh/zshrc.zwc
chmod 777 /etc/zsh/zshrc.zwc

# Set Shell for Current User
echo $(awk -F: "\$3 >= $UID_MIN && \$3 <= $UID_MAX {print \$0}" /etc/passwd) | while read userLine 
do
    user=$(echo $userLine | cut -d: -f1)
    home=$(echo $userLine | cut -d: -f6)
    echo Set configuration for user $user in $home
    chsh --shell `which zsh` $user
    touch $home/.zshrc

    # Initialize new Shell
    runuser -l $user -c 'zsh -c "source /etc/zsh/zshrc"; nvm install 18'
    chmod 777 /etc/zsh/zshrc.zwc
    
    copyOrLink $BASE_DIR/vimrc $home/.vimrc
done

touch ~/.zshrc
chsh --shell `which zsh` root
chown -R root:root /usr/local/share/zsh
chmod -R go-w /usr/local/share/zsh

zsh -c "source /etc/zsh/zshrc; nvm install 18"
chmod 777 /etc/zsh/zshrc.zwc
