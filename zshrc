SAVEHIST=10
HISTFILE=~/.zsh_history

# export NVM_DIR="/opt/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

escape() {
  while read data;
  do echo "$data" | perl -wpe "s/'/'\"'\"'/g" | perl -wpe 's/\n/\\n/g' | perl -wpe 's/\\/\\\\/g';
  done;
}

install-current-profile-to() {
  scp ~/.profile $1:~/.profile
  scp ~/.zshrc $1:~/.zshrc

  ssh -t $1 "bash -c \"[ ! -d '/usr/local/zinit' ] && sudo git clone https://github.com/zdharma/zinit.git /usr/local/zinit\""
  ssh -t $1 "chsh -s \`which zsh\`"
}

lazy_source () {
  eval "$1 () { [ -f $2 ] && source $2 && $1 \$@ }"
}

export PATH="/usr/local/sbin:$PATH"

source ~/.zinit/bin/zinit.zsh

autoload colors
colors
MAILCHECK=0

NO_PROXY=*

source ~/.profile

set_title_term () {
  echo -ne "\033]0;${1%% *} - $(pwd)\007"
}

unset_title_term () {
  echo -ne "\033]0;$(pwd)\007"
}
add-zsh-hook preexec set_title_term
add-zsh-hook precmd unset_title_term
#test -e "${HOME}/.iterm2_shell_integration.zsh" && lazy_source iterm2 "${HOME}/.iterm2_shell_integration.zsh"
