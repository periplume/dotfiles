# .bashrc
# github.com/periplume/dotfiles.git
#set -x
# TODO make this into an array
DOTFILES_REMOTE=https://github.com/periplime/dotfiles
# we can report the number of remotes easily
# and iterate through them

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
reverse=$(tput rev)
reset=$(tput sgr0)

# set the prompt
#export PS1="\[$blue\]\u \[$green\]\h \[$purple\]\w \[$yellow\]$ \[$reset\]"

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
	# fix this shit and call a local and b remote
  local a="master" b="origin/master"
  local base=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME merge-base $a $b )
  local aref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $a )
  local bref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $b )

	# test if remote is reachable
	curl ${DOTFILES_REMOTE} -sIo /dev/null
	if test "$?" -eq 0
	then
		echo "remote ${DOTFILES_REMOTE} is ${green}reachable${reset}."
	else
		echo "remote ${DOTFILES_REMOTE} is ${red}not reachable${reset}."
		echo "WARNING: no remote reachable and thus no backup."
	fi

	# test if local working tree is clean or not
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet
	if test "$?" -eq 0
	then
		echo "local working files are ${green}clean${reset}."
	else
		echo "local working files are ${red}dirty${reset}."
		git --git-dir=$HOME/.dotfiles --work-tree=$HOME status -s
	fi
	
	# test if there are staged files not committed
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet --cached --exit-code
	if test "$?" -eq 0
	then
		echo "local dotfiles repo is ${green}consistent${reset}."
	else
		echo "local dotfiles has ${yellow}uncommited changes${reset}."
	fi
	
	# test sync of local with remote
  if [[ $aref == "$bref" ]]; then
    echo "local is ${green}up-to-date${reset} $aref $bref"
		# TODO let bash snip this string to show first 5 of hash
  elif [[ $aref == "$base" ]]; then
    echo "local is ${yellow}behind${reset} $aref $bref"
  elif [[ $bref == "$base" ]]; then
    echo "local is ${yellow}ahead${reset} $aref $bref"
  	git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-list --left-right --count master...origin/master
  else
    echo ${red}diverged${reset} $aref $bref
  fi
}

# set dynamic prompt displaying various data
function dotfile_prompt() {
	_lastExit="$?"
	_promptString=""
	# test if local working tree is clean or not
  if git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet
	then
		_promptString+="${green}c${reset} "
	else
		_promptString+="${red}d${reset} "
	fi
	# change prompt indicator to red/green based on last command exit status
	if [ $_lastExit != 0 ]
	then
		_promptString+="${red}$ "
	else
		_promptString+="${green}$ "
	fi
	echo ${_promptString}
}

export PS1='\[$blue\]\u \[$green\]\h \[$purple\]\w $(dotfile_prompt) \[$reset\]'

# source platform-specific files
[ "$(uname)" = "Darwin" ] && source .bashrc_mac || true
[ "$(uname)" = "Linux" ] && source .bashrc_linux || true
