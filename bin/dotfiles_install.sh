#!/usr/bin/env bash
#
# github.com/periplume/dotfiles.git
#

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


exit
# copy latest .bashrc into $HOME/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout HEAD .bashrc


#diff .bashrc <(git --no-pager --git-dir=$HOME/.dotfiles/ --work-tree=$HOME show master:.bashrc) &> /dev/null
diff -q .bashrc <(git --no-pager --git-dir=$HOME/.dotfiles/ --work-tree=$HOME show master:.bashrc)
if [ $? = 0 ]
then
	echo "BASHRC: same"
else
	echo "BASHRC: different"
fi
echo "TEST"
# copy latest .bashrc into $HOME/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout HEAD .bashrc
