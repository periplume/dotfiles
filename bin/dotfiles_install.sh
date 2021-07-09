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

# bash best practice settings
set -o errexit
set -o nounset
set -o pipefail

# check for dependencies here by platform
if [ $(uname) = Darwin ]
then
	sudo xcode-select --install
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install --cask iterm2
	brew install git
	brew install pass
	brew install vim
	brew install fzf
	brew tap xwmx/taps
	brew install nb
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
# we can do this without awk i'm sure!
repofiles=$(git --no-pager --git-dir=$HOME/.dotfiles/ --work-tree=$HOME ls-tree -r master | awk '{print $4}')
for i in $repofiles
do
	if [ -f $i ]
	then
		mv $i $i.dotfile_backup
		echo "NOTICE: moving $i to $i.dotfile_backup"
	fi
done

# strange sequence required for this to work...
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote remove origin
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote add origin https://github.com/periplume/dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote update
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push --set-upstream origin master
# git push --set-upstream origin master

# copy latest .bashrc into $HOME/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout

