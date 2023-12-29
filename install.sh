#!/usr/bin/env bash


BASE_DIR=$(dirname "$0")
USE_LINK="${USE_LINK:-NO}"

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
if [[ "$USE_LINK" == "YES" ]]; then
	ln -s $BASE_DIR/vimrc /etc/vimrc
else
	cp $BASE_DIR/vimrc /etc/vimrc
fi

# Install Vim
rm -rf /etc/vim
if [[ "$USE_LINK" == "YES" ]]; then
	ln -s $BASE_DIR/vim /etc/vim
else
	cp -r $BASE_DIR/vim /etc/vim
fi

# Install Zshrc
rm -rf /etc/zsh/zshrc
if [[ "$USE_LINK" == "YES" ]]; then
	ln -s $BASE_DIR/zshrc /etc/zsh/zshrc
else
	cp $BASE_DIR/zshrc /etc/zsh/zshrc
fi

touch ~/.zshrc

# Install catfile
if [[ "$USE_LINK" == "YES" ]]; then
	ln -s $BASE_DIR/cat-file.sh /usr/local/bin/catfile
else
	cp $BASE_DIR/cat-file.sh /usr/local/bin/catfile
fi

# Install antigen
mkdir -p /usr/share/zsh-antigen
if [[ "$USE_LINK" == "YES" ]]; then
	ln -s $BASE_DIR/antigen.zsh /usr/share/zsh-antigen/antigen.zsh
else
	cp $BASE_DIR/antigen.zsh /usr/share/zsh-antigen/antigen.zsh
fi

UID_MIN=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
UID_MAX=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)

touch /etc/zsh/zshrc.zwc
chmod 777 /etc/zsh/zshrc.zwc

# Set Shell for Current User
echo $(awk -F: "\$3 >= $UID_MIN && \$3 <= $UID_MAX {print \$0}" /etc/passwd) | while read userLine 
do
    user=$(echo $userLine | cut -d: -f1)
    home=$(echo $userLine | cut -d: -f6)
    chsh --shell `which zsh` $user
    touch $home/.zshrc

    # Initialize new Shell
    runuser -l $user -c 'zsh -c "source /etc/zsh/zshrc"; nvm install 18'
    chmod 777 /etc/zsh/zshrc.zwc
done

touch ~/.zshrc
chsh --shell `which zsh` root
chown -R root:root /usr/local/share/zsh
chmod -R go-w /usr/local/share/zsh

zsh -c "source /etc/zsh/zshrc; nvm install 18"
chmod 777 /etc/zsh/zshrc.zwc
