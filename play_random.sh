#!/bin/bash

limit=-0
dir=false

FILETYPES="mp3|wma|flac|caf|wav|ogg|flv|avi|mp4|mov"

HELP="
Utilisation : $0 [OPTION] [RÉPERTOIRES]
Lit aléatoirement une fois chacun tous des fichiers $FILETYPES
de l'arborescence du dossier courant ou des arborescences des
RÉPERTOIRES si renseignés.

OPTIONS
-n L  ou --limit L    limite la lecture à L fichiers
-n -L ou --limit -L   lit tous les fichiers sauf L
-d N  ou --depth N    limite la recherche à N niveaux
                      de l'arborescence
--directory           lis aléatoirement par répertoire"

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o d:n:h --long depth:,limit:,help,directory -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-n|--limit) limit=$2 ; shift 2 ;;
		-d|--depth) depth="-maxdepth $2" ; shift 2 ;;
		--directory) dir=true ; shift ;;
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
    find "$d" -maxdepth 1 -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | sort -R > .playlist
    if (( $(wc -l < .playlist) > 0 ))
    then
      print_len
      mplayer -playlist .playlist
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
  mplayer -playlist .playlist
fi
