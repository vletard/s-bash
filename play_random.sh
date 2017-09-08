#!/bin/bash

limit=-0
dir=false
sub_dir=-R
mpoptions=

FILETYPES="mp3|wma|flac|caf|wav|ogg|flv|avi|mp4|mov"

HELP="
Usage: $0 [OPTIONS] [DIRECTORIES]
Plays each file of types $FILETYPES
found in the specified directories in random order.
If not directory is specified, the working directory is searched
for files to play.

OPTIONS
-n L  ou --limit L    limits the playlist to L files
-n -L ou --limit -L   plays every file but the last L
-d N  ou --depth N    limits the search to N levels of depth
--directory           group the played files by directory
--straight-dir        keep every file in each directory in their natural ordering
--novideo             only plays the audio of each file"

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o d:n:h --long novideo,depth:,limit:,help,directory,straight-dir -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-n|--limit) limit=$2 ; shift 2 ;;
    --novideo) mpoptions="$mpoptions -novideo"; shift ;;
		-d|--depth) depth="-maxdepth $2" ; shift 2 ;;
		--directory) dir=true ; shift ;;
		--straight-dir) sub_dir= ; shift ;;
		-h|--help) echo "$HELP"
                           exit 0 ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

################ End example ##########################################################

function print_len {
  IFS='
'
  len=0
  for track in $(cat .playlist)
  do
    time=$(mp3info -p "%S" $track)
    if (( $? != 0 ))
    then
      len=-1
      break
    fi
    len=$(( $len + $time ))
  done
  if (( $len > -1 ))
  then
    echo -n "Durée totale : "
    h=$(( $len / 3600 ))
    if (( $h > 0 ))
    then
      echo -n "$h""h "
      len=$(( $len % 3600 ))
    fi
    m=$(( $len / 60 ))
    if (( $h > 0 || $m > 0 ))
    then
      echo -n "$m""m "
      len=$(( $len % 60 ))
    fi
    echo "$len""s "
    echo
  fi
}

trap "mv -v .playlist /tmp/" EXIT SIGINT SIGKILL

if $dir
then
  IFS='
'
  for d in $(find "$@" $depth -regextype posix-extended -type d | sort -R)
  do
    find "$d" -maxdepth 1 -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | sort $sub_dir > .playlist
    if (( $(wc -l < .playlist) > 0 ))
    then
      print_len
      IFS=' '
      mplayer $mpoptions -playlist .playlist
      IFS='
'
      read -p "Continuer avec le répertoire suivant ? [O/n]" -sn 1 -t 5 cont
      echo
      if ! ([ "$cont" = "" ] || [ "$cont" = "o" ] || [ "$cont" = "O" ])
      then
        exit
      fi
    fi
  done
else
  find "$@" $depth -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | sort -R | head -n $limit > .playlist
  print_len
  IFS=' '
  mplayer $mpoptions -playlist .playlist
fi
