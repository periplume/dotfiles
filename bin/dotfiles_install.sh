#!/usr/bin/env bash
#
# github.com/periplume/dotfiles
#
# checks for existence of $HOME/.dotfiles; exits if exists
# clones the dotfiles repo in the bare style
# sets git to ignore everything but in this repo
# copies existing file into backup copy as a lame precaution
# checks out all dotfiles into $HOME and sets upstream branch
# at that point dotfiles is in working order
#
# https://raw.githubusercontent.com/periplume/dotfiles/master/bin/dotfiles_install.sh
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/periplume/dotfiles/master/bin/dotfiles_install.sh)"

# bash best practice settings
set -o errexit
set -o nounset
set -o pipefail

_command_exists() {
  hash "${1}" 2>/dev/null
}

# check for dependencies here by platform
if [ $(uname) = Darwin ]
then
	if ! _command_exists "git"
	then
  	echo "ERROR: missing git...install xcode and other tools:"
		echo "# sudo xcode-select --install"
		echo "# /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
		echo "# brew install bash"
		echo "# sudo echo /usr/local/bin/bash >> /etc/shells"
		echo "# this last command might not work...?"
		echo "# chsh -s /usr/local/bin/bash"
		echo "# brew install --cask iterm2"
		echo "# brew install git"
		echo "# brew install pass"
		echo "# brew install vim"
		echo "# brew install fzf"
		echo "# brew tap xwmx/taps"
		echo "# brew install nb"
		echo "  install the above, then try again"
  	exit 1
	fi
fi

# check that ~/.dotfiles does not exist
if [ -d "$HOME/.dotfiles" ]
then
	echo "error: ~/.dotfiles already exists"
	echo "try: dotfiles pull"
	exit 1
fi

# clone the dotfiles repo
git clone --bare https://github.com/periplume/dotfiles.git $HOME/.dotfiles

# instruct git to ignore untracked files in this repo
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no

# list the files in the dotfiles repo (may conflict with existing)
repofiles=$(git --no-pager --git-dir=$HOME/.dotfiles/ --work-tree=$HOME ls-tree -r master | awk '{print $4}')
# we can do this without awk i'm sure!
# make backups of the dotfiles about to be replaced
# TODO this is not safe!
for i in $repofiles
do
	if [ -f $i ]
	then
		mv $i $i.dotfile_backup
		echo "NOTICE: moving $i to $i.dotfile_backup"
	fi
done

# strange sequence required to set up the remote tracking...
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote remove origin
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote add origin https://github.com/periplume/dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote update
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push --set-upstream origin master

# copy all dotfiles into $HOME/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
# TODO use sparse checkout to refine/control what lands in $HOME

