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
for i in $repofiles
do
	if [ -f $i ]
	then
		mv $i $i.dotfile_backup
	fi
done

# copy latest .bashrc into $HOME/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push -u origin master

