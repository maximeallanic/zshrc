#!/usr/bin/env sh


BASE_DIR=$(dirname "$0")

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
rm -rf /etc/vimrc
ln -s $BASE_DIR/vimrc /etc/vimrc

# Install Vim
rm -rf /etc/vim
ln -s $BASE_DIR/vim /etc/vim

# Install Zshrc
rm -rf /etc/zsh/zshrc
ln -s $BASE_DIR/zshrc /etc/zsh/zshrc

touch ~/.zshrc

# Install catfile
ln -s $BASE_DIR/cat-file.sh /usr/local/bin/catfile

UID_MIN=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
UID_MAX=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)

# Set Shell for Current User
echo $(awk -F: "\$3 >= $UID_MIN && \$3 <= $UID_MAX {print \$0}" /etc/passwd) | while read userLine 
do
    user=$(echo $userLine | cut -d: -f1)
    home=$(echo $userLine | cut -d: -f6)
    chsh --shell `which zsh` $user
    touch $home/.zshrc

    # Initialize new Shell
    runuser -l $user -c 'zsh -c "source /etc/zsh/zshrc"'
done

touch ~/.zshrc
chsh --shell `which zsh` root
chown -R root:root /usr/local/share/zsh
chmod -R go-w /usr/local/share/zsh

zsh -c "source /etc/zsh/zshrc"
chmod 777 /etc/zsh/zshrc.zwc
ls -la /etc/zsh/zshrc.zwc
