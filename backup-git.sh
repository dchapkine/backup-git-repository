#!/bin/bash

#
# detect no args
#
if [ $# -eq 0 ]; then
	ARG_HELP="Y"
fi

#
# default args
#
ARG_DRY='N'

#
# parse args
#
while [[ $# > 1 ]]
do
key="$1"

case $key in

	-i|--input)
	ARG_SRC_DIR="$2"
	shift
	;;

	-o|--output)
	ARG_DST_DIR="$2"
	shift
	;;

	# mode can be: 'flat' or 'tree'
	-m|--mode)
	ARG_MODE="$2"
	shift
	;;

	# dry run
	-d|--dry)
	ARG_DRY="$2"
	shift
	;;

	*)
		# unknown option
	;;
esac
shift
done


#
# apply filters
#
ARG_SRC_DIR=$(echo "$ARG_SRC_DIR" | sed -e 's#/$##')
ARG_DST_DIR=$(echo "$ARG_DST_DIR" | sed -e 's#/$##')

#
# validate input
#
echo ""
if [ "$ARG_HELP" = 'Y' ]; then
	echo "USAGE: ./backup-git.sh -i SRC_DIR -o DST_DIR -m MODE"
	echo "  -i: directory path, where to look for git repositoies to backup"
	echo "  -o: directory path, where to store backups"
	echo "  -m: output mode: recursive 'tree', or 'flat' named backups all in one folder"
	echo ""
	echo "EXAMPLE 1: ./backup-git.sh -i ~/git -o ~/tmp -m flat"
	echo "  => means recursively backup all git repos in ~/git into ~/tmp, using flat structure"
	echo ""
	echo "EXAMPLE 2: ./backup-git.sh -i ~/git -o ~/tmp -m tree --dry yes"
	echo "  => dry run"
	echo ""
	echo "EXAMPLE 3: ./backup-git.sh -i ~/git -o ~/tmp -m tree --dry yes > real_backup.sh"
	echo "  => what's cool about dry run, is that you can actualy save the output as script, to run it later"
	echo ""
	exit 1
elif [ ! -d "$ARG_SRC_DIR" ]; then
	echo "ERROR: source folder doesn't exist (-i)"
	$BASH_SOURCE
	exit 1
elif [ -z "$ARG_DST_DIR" ]; then
	echo "ERROR: destination folder is required (-o)"
	$BASH_SOURCE
	exit 1
elif [ -z "$ARG_MODE" ]; then
	echo "ERROR: mode is required (-m: flat or tree)"
	$BASH_SOURCE
	exit 1
elif [[ "$ARG_MODE" != "flat" && "$ARG_MODE" != "tree" ]]; then
	echo "ERROR: bad mode value (-m: flat or tree)"
	$BASH_SOURCE
	exit 1
fi

#
# backup git repositories
#
echo "# Backing up git"
echo ""
for dir in `find $ARG_SRC_DIR -name .git -type d -prune`
do
	srcdir=`realpath $dir/..`
	outdir=${srcdir#$ARG_SRC_DIR/}
	gitbackupdir="$ARG_DST_DIR/git"

	# tree mode
	fulloutdir="$gitbackupdir/$outdir"
	fulloutfile="$fulloutdir/git_$(date +%Y%m%d_%H%M%S).git"

	# flat mode
	standalonefile=$(echo "$outdir" | tr / _$)
	fullstandalonefile="$gitbackupdir/$standalonefile""_$(date +%Y%m%d_%H%M%S).git"

	#
	if [ "$ARG_MODE" == "flat" ]; then

		echo "# Starting $srcdir backup to $fullstandalonefile"

		if [ "$ARG_DRY" == "N" ]; then
			mkdir -p "$gitbackupdir"
			cd "$srcdir"
			git bundle create "$fullstandalonefile" --all &>> /dev/null
		else
			echo "mkdir -p \"$gitbackupdir\""
			echo "cd \"$srcdir\""
			echo "git bundle create \"$fullstandalonefile\" --all &>> /dev/null"
		fi
		echo ""

	elif [ "$ARG_MODE" == "tree" ]; then

		echo "# Starting $srcdir backup to $fulloutdir"

		if [ "$ARG_DRY" == "N" ]; then
			mkdir -p "$fulloutdir"
			cd "$srcdir"
			git bundle create "$fulloutfile" --all &>> /dev/null
		else
			echo "mkdir -p \"$fulloutdir\""
			echo "cd \"$srcdir\""
			echo "git bundle create \"$fulloutfile\" --all &>> /dev/null"
		fi
		echo ""
	fi


done

