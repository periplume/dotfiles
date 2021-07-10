# .bashrc
# github.com/periplume/dotfiles.git

# if not running interactive shell, exit
[[ $- != *i* ]] && return

# be quiet
set bell-style visible

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
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

# set the prompt
export PS1="\[$blue\]\u \[$green\]\h \[$purple\]\w \[$yellow\]$ \[$reset\]"

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
dotfiles () {
	if [[ $1 = "help" ]] || [[ -z "$1" ]]
	then
		echo "dotfiles: manage dotfiles with git"
		echo "usage: dotfiles status|add|commit|push|pull"
    echo "workflow: ${green}'dotfiles add .bash_profile'${reset}  to add changes to .bash_profile to repo"
		echo "          'dotfiles commit -m \"fixed such and such\"  to commit changes to repo"
		echo "          'dotfiles push' to push changes to upstream repo"
	else
		/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
	fi
}

function dotfiles_status() {
  local a="master" b="origin/master"
  local base=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME merge-base $a $b )
  local aref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $a )
  local bref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $b )

  if [[ $aref == "$bref" ]]; then
    echo ${green}up-to-date${reset} $aref $bref
  elif [[ $aref == "$base" ]]; then
    echo ${yellow}behind${reset} $aref $bref
  elif [[ $bref == "$base" ]]; then
    echo ${yellow}ahead${reset} $aref $bref
  else
    echo ${red}diverged${reset} $aref $bref
  fi

	# check if local working tree is dirty or clean
	git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet && echo "local is ${green}clean${reset}"
	git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet || echo "local is ${red}dirty${reset}" && git --git-dir=$HOME/.dotfiles --work-tree=$HOME status -s
}

# unfinished
# build PS1 to include =+- in color to represent dotfiles status
# local = dirty (red) or clean (green)
# remote = ahead (yellow) or behind (yellow) or same (green) or neither (red)
# set these as ENV in function called by PS1
function dotfile_prompt() {
	local _dotfile_local=0
}

# source platform-specific files
[ "$(uname)" = "Darwin" ] && source .bashrc_mac
[ "$(uname)" = "Linux" ] && source .bashrc_linux

# used this to get latest git in ubuntu 18 testing git remote sync setup
# likely can remove
#[ "$(uname)" = Linux ] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
