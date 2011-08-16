#alias ls="ls --color=auto"
export CLICOLOR=1
alias ll="ls -lFgh"
alias l="ll -A"

c() {
  cd "$1";
  l;
}

PS1="\$ "

export EDITOR="vim"
export SVN_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR

export PAGER=~/.bin/vimpager
alias less=$PAGER

PATH=~/.bin:$PATH
export PATH

export NODE_PATH='/usr/local/lib/node'

