# Configure Key of term
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey  "^[[3~"  delete-char

# Configure NVM
#export NVM_DIR="$HOME/.nvm"
#  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
#  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Configure RVM
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && lazy_source rvm "$HOME/.rvm/scripts/rvm" # This Load RVM into a shell session *as a function*

#if which swiftenv > /dev/null; then
#  eval "$(swiftenv init -)"
#fi

export ANDROID_HOME=/usr/local/Caskroom/android-sdk/4333796/
export ANDROID_NDK_HOME=$ANDROID_HOMEndk-bundle

export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle

export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/19.1.0:$PATH


#export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"
#source "/opt/google-cloud-sdk/path.zsh.inc"
#source "/opt/google-cloud-sdk/completion.zsh.inc"

# Configure Plugins

#zinit ice wait lucid
zinit load zsh-users/zsh-completions

#zinit ice wait lucid
zinit load zsh-users/zsh-autosuggestions

#zinit ice wait lucid
zinit snippet OMZ::lib/git.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/docker/_docker

#zinit ice wait lucid
zinit snippet OMZ::plugins/docker-compose/_docker-compose

#zinit ice wait lucid
zinit snippet OMZ::plugins/man/man.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/autojump/autojump.plugin.zsh

#zinit ice wait lucid
#zinit snippet OMZ::plugins/aws/aws.plugin.zsh

#zinit ice wait lucid
#zinit snippet OMZ::plugins/bower/bower.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/composer/composer.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/git-extras/git-extras.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/symfony2/symfony2.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/safe-paste/safe-paste.plugin.zsh

#zinit ice wait lucid
zinit load zsh-users/zsh-history-substring-search

#zinit ice wait lucid
zinit snippet OMZ::plugins/extract/extract.plugin.zsh

# zinit ice wait lucid
zinit snippet OMZ::plugins/last-working-dir/last-working-dir.plugin.zsh

#zinit ice wait lucid
zinit snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

#zinit ice wait lucid pick'init.zsh' compile'*.zsh'
#zinit light laggardkernel/zsh-iterm2

#zinit ice wait lucid
zinit load hlissner/zsh-autopair

zinit ice wait lucid svn pick"/dev/null" multisrc"{completion,git,nvm,diagnostics,correction,clipboard,cli}.zsh"
zinit snippet OMZ::lib

#zinit ice wait lucid
zinit load voronkovich/gitignore.plugin.zsh

# zinit ice wait lucid
# zinit load lukechilds/zsh-nvm

#zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit load lukechilds/zsh-better-npm-completion

#zinit ice wait lucid
#zinit load zsh-users/zsh-apple-touchbar

#zinit ice wait lucid
#zinit load arzzen/calc.plugin.zsh

#zinit ice wait lucid
zinit load mattmc3/zsh-safe-rm

#zplugin ice wait'1' lucid
#zplugin light laggardkernel/zsh-thefuck

zinit load zsh-users/zsh-syntax-highlighting

# Configure Prompt
#ZSH_THEME_GIT_PROMPT_PREFIX="$fg_bold[blue]git($reset_color$fg_bold[red]"
#ZSH_THEME_GIT_PROMPT_SUFFIX=""
#ZSH_THEME_GIT_PROMPT_DIRTY="$reset_color$fg_bold[blue])$reset_color $fg[yellow]✘$reset_color "
#ZSH_THEME_GIT_PROMPT_CLEAN="$reset_color$fg_bold[blue])$reset_color $fg[yellow]✔$reset_color "

zinit cdclear -q
setopt promptsubst
#zinit snippet OMZT::robbyrussell

PROMPT=""
if [ `whoami` = "root" ]; then
  PROMPT+='%{$fg[red]#$reset_color%} '
fi
PROMPT+="%(?:%{$fg_bold[green]%}-> :%{$fg_bold[red]%}➜ )"
PROMPT+='%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

#setopt prompt_subst
#local ret_status="%(?:$fg_bold[green]➜:$fg_bold[red]➜%s)"
#local user_status=''
#if [ `whoami` = "root" ]; then
#  local user_status='$fg[red]#$reset_color '
#fi
#PROMPT=$user_status'$ret_status $fg[cyan]%~$reset_color $(git_prompt_info)'


# Configure alias
alias vi="vim"
alias tmp="cd /tmp"
#alias cat="ccat"
alias ls="ls -G"
#alias rm="trash"
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'


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
  if [ -e .env ]; then
    eval $(cat .env | sed 's/^/export /')
  fi
}

update_from_directory
add-zsh-hook chpwd update_from_directory
