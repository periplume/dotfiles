# .bashrc
# github.com/periplume/dotfiles.git
#set -x
# TODO make this into an array
DOTFILES_REMOTE=https://github.com/periplime/dotfiles
# 
# we can report the number of remotes easily
# and iterate through them

# make this bashrc usable in case dotfiles is not working or set up
# or if we don't have access to git and curl
if ! hash git
then
	DOTFILES_DISABLE=true
fi
# i could also consider putting all dotfiles work into its own file and sourcing
# it?

# if not running interactive shell, exit
[[ $- != *i* ]] && return

# be quiet for godsake
set bell-style visible

# bash history settings
# append to the history file, don't overwrite it
shopt -s histappend
# flush out bash history every command
#PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=10000
HISTTIMEFORMAT="%s %F %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set up color variable shortcuts
# fix this up with better names
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
	if [[ $1 = "help" ]]
	then
		echo "dotfiles: manage dotfiles with git"
		echo "usage: dotfiles status|add|commit|push|pull"
    echo "workflow: ${green}'dotfiles add .bash_profile'${reset}  to add changes to .bash_profile to repo"
		echo "          'dotfiles commit -m \"fixed such and such\"  to commit changes to repo"
		echo "          'dotfiles push' to push changes to upstream repo"
	elif [[ -z "$1" ]]
	then
		dotfiles_status
	else
		# look for push and do it with nohup...and watch for the exit code?
		/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
	fi
}
# add an alias for finger convenience
alias dotfi=dotfiles

# improve this
function dotfiles_status() {
  local a="master" b="origin/master"
  local base=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME merge-base $a $b )
  local aref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $a )
  local bref=$( git --git-dir=$HOME/.dotfiles --work-tree=$HOME rev-parse  $b )

	# test if local working tree is clean or not
  if dotfiles diff --quiet
	then
		echo "local working files are ${green}clean${reset}."
	else
		echo "local working files are ${red}dirty${reset}:"
		dotfiles status -s
	fi
	
	# test if there are staged files not committed
  if dotfiles diff --quiet --cached --exit-code
	then
		echo "local dotfiles repo is ${green}consistent${reset}."
	else
		echo "local dotfiles has ${yellow}uncommited changes${reset}."
	fi
	
	# test if remote is reachable
	if curl ${DOTFILES_REMOTE} -sIo /dev/null
	then
		echo "remote ${DOTFILES_REMOTE} is ${green}reachable${reset}."
		# update local with changes from remote
		dotfiles remote update 1> /dev/null || echo "FAILED to update from remote"
		# reset the bref which is remote a
  	local bref=$(dotfiles rev-parse  $b )
		# probably a pull here to put the updated files into place?
		# no, be careful, need to check the sync status before doing anything
		# we are just updating the local repo with new changes
		# if we don't have dirty files and if the repo is consistent
		# then we can do a pull, which will replace the working tree with the
		# versions from the remote...ahead of us.
	else
		echo "remote ${DOTFILES_REMOTE} is ${red}not reachable${reset}."
		echo "${yellow}WARNING${reset}: no remote reachable and thus no backup."
	fi
	
	# test sync of local with remote refs as tracked in local
  if [[ $aref == "$bref" ]]; then
    echo "local ${a} ${aref:0:7} ${green}in-sync${reset} with remote ${b} ${bref:0:7}"
  elif [[ $aref == "$base" ]]; then
		echo "local ${a} ${aref:0:7} is ${yellow}behind${reset} remote ${b} ${bref:0:7}"
		dotfiles rev-list --left-right --count ${a}...${b}
  elif [[ $bref == "$base" ]]; then
		echo "local ${a} ${aref:0:7} is ${yellow}ahead${reset} of remote ${b} ${bref:0:7}"
		dotfiles rev-list --left-right --count ${a}...${b}
  else
		echo "local ${a} ${aref:0:7} is ${red}diverged${reset} from remote ${b} ${bref:0:7}"
		dotfiles rev-list --left-right --count ${a}...${b}
  fi
}

# set dynamic prompt displaying various data
# https://stackoverflow.com/questions/16715103/bash-prompt-with-the-last-exit-code
# it seems that using tput to do the colors breaks readline/history
# where as using ascii color codes works fine

# do an if here to check for DOTFILES_DISABLE=true
# if true, set PS1 as static
# else, set PROMPT_COMMAND with the fancy function below

# also fix this problem...i was using PROMPT_COMMAND to flush bash history to
# the history file after every command...which broke...so add the history
# command to the __prompt_command and the static PS1 build above
PROMPT_COMMAND=__prompt_command
__prompt_command() {
    local _lastExit="$?"
		# flush out bash history every command
		history -a
		# now get to buisness
		local _localRepo=$(dotfiles rev-list --max-count=1 master)
		local _remoteRepo=$(dotfiles rev-list --max-count=1 origin/master)
		local reset='\[\e[0m\]'
    local red='\[\e[0;31m\]'
    local redbold='\[\e[1;31m\]'
    local green='\[\e[0;32m\]'
    local yellowbold='\[\e[1;33m\]'
    local bluebold='\[\e[1;34m\]'
    local blue='\[\e[0;34m\]'
    local purple='\[\e[0;35m\]'

		# show user host and working dir first
		PS1="${blue}\u${reset} ${green}\h${reset} ${purple}\w${reset} "

		# test if local working tree is clean or not
		if git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet
		then
			PS1+="${green}c${reset}"
		else
			PS1+="${red}d${reset}"
		fi

		# test if there are staged files not committed
		if git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --quiet --cached --exit-code
		then
			PS1+="${green}=${reset}"
		else
			PS1+="${redbold}-${reset}"
		fi

		# test if local repo is in sync with remote
  	if [[ $_localRepo == "$_remoteRepo" ]]; then
			PS1+="${green}o${reset} "
		else
			PS1+="${redbold}x${reset} "
		fi

		# change prompt color based on last command exit status
    if [ $_lastExit != 0 ]; then
        PS1+="${red}\$${reset} "
    else
        PS1+="${green}\$${reset} "
    fi
}

# source platform-specific files
[ "$(uname)" = "Darwin" ] && source .bashrc_mac || true
[ "$(uname)" = "Linux" ] && source .bashrc_linux || true
