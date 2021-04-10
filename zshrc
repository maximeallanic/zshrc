#
# /etc/zshrc is sourced in interactive shells.  It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
## shell functions
#setenv() { export $1=$2 }  # csh compatibility
# Set prompts
#PROMPT='[%n@%m]%~%# '    # default prompt
#RPROMPT=' %~'     # prompt for right side of screen
# bindkey -v             # vi key bindings
# bindkey -e             # emacs key bindings
bindkey ' ' magic-space  # also do history expansion on space
# Provide pathmunge for /etc/profile.d scripts
pathmunge() {
    if ! echo $PATH | /bin/grep -qE "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    elif [[ ! -o login ]]; then # We're not a login shell
    fi
}

_src_etc_profile_d() {
    #  Make the *.sh things happier, and have possible ~/.zshenv options like
    # NOMATCH ignored.
    emulate -L ksh


    # from bashrc, with zsh fixes
    if [[ ! -o login ]]; then # We're not a login shell
        for i in /etc/profile.d/*.sh; do
            if [ -r "$i" ]; then
                . $i
            fi
        done
        unset i
    fi
}

_src_etc_profile_d
unset -f pathmunge _src_etc_profile_d

SAVEHIST=10
HISTFILE=~/.zsh_history
unset MAILCHECK

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

export PATH="/usr/local/sbin:/sbin:$PATH"

setopt nonomatch                                                                                                                                       
setopt re_match_pcre                                                                                                                                   
setopt EXTENDED_GLOB     

autoload colors
colors
MAILCHECK=0

NO_PROXY=*

source /usr/local/share/antigen.zsh

# Configure Key of term
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey  "^[[3~"  delete-char

# Configure NVM
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Configure RVM
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && lazy_source rvm "$HOME/.rvm/scripts/rvm" # This Load RVM into a shell session *as a function*


# Configure Global Path
#export ANDROID_HOME=/usr/local/Caskroom/android-sdk/4333796/
#export ANDROID_NDK_HOME=$ANDROID_HOMEndk-bundle

export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle

export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
#export PATH=$ANDROID_HOME/tools:$PATH
#export PATH=$ANDROID_HOME/platform-tools:$PATH
#export PATH=$ANDROID_HOME/build-tools/19.1.0:$PATH


# Configure Plugins

antigen use oh-my-zsh

antigen bundle git
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle docker
antigen bundle docker-compose
antigen bundle man
antigen bundle autojump
antigen bundle bower
antigen bundle composer
antigen bundle git-extras
antigen bundle sudo
antigen bundle symfony2
antigen bundle safe-paste
antigen bundle completion
antigen bundle nvm
antigen bundle diagnostics
antigen bundle correction
antigen bundle clipboard
antigen bundle cli
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle extract
antigen bundle last-working-dir
antigen bundle command-not-found
antigen bundle hlissner/zsh-autopair
antigen bundle voronkovich/gitignore.plugin.zsh
antigen bundle lukechilds/zsh-better-npm-completion
#antigen bundle arzzen/calc.plugin.zsh
antigen bundle mattmc3/zsh-safe-rm
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme robbyrussell

# Tell Antigen that you're done.
antigen apply

#zinit load zpm-zsh/colorize

# Configure Prompt
#ZSH_THEME_GIT_PROMPT_PREFIX="$fg_bold[blue]git($reset_color$fg_bold[red]"
#ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="$reset_color$fg_bold[blue])$reset_color $fg[red]x$reset_color "  
ZSH_THEME_GIT_PROMPT_CLEAN="$reset_color$fg_bold[blue])$reset_color "

#setopt promptsubst

PROMPT=""
if [ `whoami` = "root" ]; then
  PROMPT+='%{$fg[red]#$reset_color%}'
fi
PROMPT+="%(?:%{$fg_bold[green]%}> :%{$fg_bold[red]%}> )"
PROMPT+='%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'



# Configure alias
alias vi="vim"
alias tmp="cd /tmp"
#alias cat="ccat"
#alias ls="grc --colour=auto ls --color=always -G"
#alias rm="trash"
#alias pbcopy='xclip -selection clipboard'
#alias pbpaste='xclip -selection clipboard -o'

function screenfetch() {
  SENSOR=$(sensors -j 2> /dev/null)
  DEVICES=$(echo $SENSOR | jq -r '.[]')
  ARGS=''
  for DEVICE in $DEVICES; do
    #NAME=$(echo $DEVICE | jq -r '')
    VALUE=$(echo $DEVICE | jq -r '.temp1.temp1_input')
    echo $VALUE
    ARGS=$ARGS+','+$NAME+'='+$VALUE 
  done
#  echo $ARGS
}

function cd() {
  if [ -z "$*" ]; then
    destination=~
  else
    destination=$*
  fi
  builtin cd "${destination}" >/dev/null
}

function jcurl() {
  curl $@ | jsonpp | pygmentize -l json
}

function public-ip() {
  curl ifconfig.me
}

function update_nvm() {
  if ! [ -x "$(command -v node)" ]; then
    nvm use default > /dev/null
  fi
  DEFAULT_VERSION=${$(nvm ls default | tr -d '[:space:]' | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g')//->/}
  CURRENT_VERSION=$(node -v)

  if [ -e .nvmrc ]
  then
    LOCAL_VERSION=$(cat .nvmrc)
  if [ $(nvm ls | grep $LOCAL_VERSION | wc -l) = "0" ]
  then
    nvm install $LOCAL_VERSION
  fi
    nvm use $LOCAL_VERSION > /dev/null
  elif [ "$DEFAULT_VERSION" != "$CURRENT_VERSION" ]
  then
    nvm use default > /dev/null
  fi
}

update_from_directory() {
  update_nvm
  if [[ -f .env && -r .env ]]; then
    source .env
  fi
}

update_from_directory
add-zsh-hook chpwd update_from_directory

[[ -s ~/.profile ]] && source ~/.profile

[[ -s /etc/grc.zsh ]] && source /etc/grc.zsh

set_title_term () {
  echo -ne "\033]0;${1%% *} - $(pwd)\007"
}

unset_title_term () {
  echo -ne "\033]0;$(pwd)\007"
}
add-zsh-hook preexec set_title_term
add-zsh-hook precmd unset_title_term
#test -e "${HOME}/.iterm2_shell_integration.zsh" && lazy_source iterm2 "${HOME}/.iterm2_shell_integration.zsh"
