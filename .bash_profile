# .bash_profile for macos
# jkl

# be quiet
set bell-style visible

# silence default shell message
export BASH_SILENCE_DEPRECATION_WARNING=1

# bash history settings
# append to the history file, don't overwrite it
shopt -s histappend
# flush out bash history every command
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=10000
HISTTIMEFORMAT="%F %T %s "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set up colors
export CLICOLOR=1
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)
#export PS1="\[$blue\]\u \[$purple\]\w \[$yellow\]$ \[$reset\]"
export PS1="\[$blue\]\u \[$green\]\h \[$purple\]\w \[$yellow\]$ \[$reset\]"

# set colors for ls
export LSCOLORS=ahfcxdxbBxbxdabagacedx

# COLORIZE LESS for man
man () {
  env \
    LESS_TERMCAP_md=$(tput bold; tput setaf 3) \
    LESS_TERMCAP_mb=$(tput bold; tput setaf 1) \
    LESS_TERMCAP_us=$(tput smul; tput setaf 2) \
    LESS_TERMCAP_ue=$(tput rmul; tput setaf 7) \
    LESS_TERMCAP_me=$(tput sgr0)               \
    LESS_TERMCAP_so=$(tput setaf 1; tput setab 2) \
    LESS_TERMCAP_se=$(tput sgr0)               \
		LESS_TERMCAP_mr=$(tput rev)                \
		LESS_TERMCAP_mh=$(tput dim)                \
		LESS_TERMCAP_ZN=$(tput ssubm)              \
		LESS_TERMCAP_ZV=$(tput rsubm)              \
		LESS_TERMCAP_ZO=$(tput ssupm)              \
		LESS_TERMCAP_ZW=$(tput rsupm)              \
    man "$@"
}
export LESS=-R
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# disable ctrl-s 
stty -ixon

# dotfiles management with git
#alias dotfiles='/usr/bin/git --git-dir=/Users/jason/.dotfiles/ --work-tree=/Users/jason'
dotfiles () {
	if [[ $1 = "help" ]] || [[ -z "$1" ]]
	then
		echo "dotfiles: manage dotfiles with git"
		echo "usage: dotfiles status|add|commit|push|pull"
	else
		/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
	fi
}

# pass completion
source /usr/local/etc/bash_completion.d/pass
