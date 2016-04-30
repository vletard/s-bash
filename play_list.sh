#!/bin/bash

limit=-0
scrobble=false

mplayer="mplayer -msglevel lirc=0:demuxer=0:subreader=0:decaudio=0:decvideo=0"

FILETYPES="mp3|wma|caf|flac|wav|ogg"

HELP="Usage : $0 PLAYLIST [OPTION]
Lit la PLAYLIST à partir des fichiers de types $FILETYPES
trouvés dans l'arborescence du répertoire courant.

OPTIONS
-l    ou --list       liste les playlists déjà définies
-d    ou --delete     supprime la playlist spécifiée
-b    ou --build      construit la playlist au lieu de
                      simplement la lire
-f    ou --from       construit à partir d'une playlist
                      plutôt que de tous les fichiers
-s    ou --scrobble   active le scrobbling (mp3info
                      doit être installé)
-n L  ou --limit L    limite la lecture à L fichiers
-n -L ou --limit -L   lit tous les fichiers sauf L"
#-d N  ou --depth N    limite la recherche à N niveaux\n
#                      de l'arborescence"

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o d:ln:bhs --long list,delete:,scrobble,build,help -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

mkdir -p .playlists

function print_entry {
  positives=$(wc -l < ".playlists/$1")
  negatives=$(wc -l < ".playlists/.$1")
  printf "%-$3s (taille : %3d - couverture : %3d%%)\n" "$1" $positives $(( (100 * ($positives + $negatives) ) / $2 ))
}

while true ; do
  case "$1" in
    -b|--build)
        build=true
        shift ;;
    -s|--scrobble)
        scrobble=true
        shift ;;
    -l|--list)
        len=$(ls -1 .playlists | wc -L)
        echo -e "Playlists disponibles :\n"
        total=$(find . -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | wc -l)
        {
          IFS=$'\n'
          for line in $(ls .playlists)
          do
            print_entry "$line" $total $len
          done
        }
        exit $? ;;
    -d|--delete)
        if ! test -f ".playlists/$2"
        then
          echo "La playlist $2 n'existe pas."
          exit
        fi
        read -p "Voulez-vous vraiment supprimer la playlist $2 ? [O/n]" -sn 1 response
        echo
        if [ "$response" == "O" ] || [ "$response" == "o" ] || [ "$response" == "" ]
        then
          mv -v ".playlists/$2" /tmp
          mv -v ".playlists/.$2" /tmp
        fi
        exit ;;
    -n|--limit) limit=$2 ; shift 2 ;;
#    -d|--depth) depth="-maxdepth $2" ; shift 2 ;;
    -h|--help) echo "$HELP"
              exit 0 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if (( $# != 1 ))
then
#  echo -e $HELP
  len=$(ls -1 .playlists | wc -L)
  echo -e "Playlists disponibles :\n"
  total=$(find . -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | wc -l)
  {
    IFS=$'\n'
    for line in $(ls .playlists)
    do
      print_entry "$line" $total $len
    done
  }
  exit 0
fi

################ End example ##########################################################

function build {
  find . -regextype posix-extended -iregex "(\./)?([^.][^/]*/)*([^.][^/]*)\.($FILETYPES)" | sort -R > .playlist
  touch ".playlists/$1"
  touch ".playlists/.$1"
  while (( $(cat .playlist | wc -l) > 0 ))
  do
    reading=$(head -n 1 .playlist)
    if (( $(grep "$reading" ".playlists/$1" 2>/dev/null | wc -l) == 0 )) && (( $(grep "$reading" ".playlists/.$1" 2>/dev/null | wc -l) == 0 ))
    then
      echo -e "\n-------- Playlist \"$1\" (editing mode) ---------"
      if which mp3info > /dev/null && $scrobble
      then
        trust=$(mp3info "$reading" -p '%c')
        if [ "$trust" = "trusted" ]
        then
          artist=$(mp3info "$reading" -p '%a')
          title=$(mp3info "$reading" -p '%n')
          duration=$(mp3info "$reading" -p '%S')
          album=$(mp3info "$reading" -p '%l')
          lastfm.sh playing -a $artist -t $title --album $album --duration $duration
        fi
      fi
      $mplayer "$reading" -slave
      case $? in
        0) newlist=$(echo "$reading"; cat ".playlists/$1")
           echo "$newlist" > ".playlists/$1"
           echo -e "\nFichier ajouté à la playlist : $reading"
           if $scrobble
           then
             if [ "$trust" = "trusted" ]
             then
               lastfm.sh scrobble -a $artist -t $title --album $album --duration $duration
             else
               echo "$reading" >> .untrusted_read
               echo "File tags are untrusted !"
             fi
           fi
           ;;
        1) newlist=$(echo "$reading"
           cat ".playlists/.$1")
           echo "$newlist" > ".playlists/.$1"
           echo -e "\nFichier ignoré pour la playlist : $reading"
           ;;
        2) break
           ;;
      esac
    fi
    toread=$(tail .playlist -n +2)
    echo "$toread" > .playlist
  done
  mv -v .playlist /tmp
}




if [ "$build" = "true" ]
then
  touch .playlist
  while [ -f .playlist ]
  do
    IFS= read -n 1 key
    case "$key" in
      ' ') echo "pause" ;;
      '-') echo "q 1" ;;
      '') echo "q 3" ;;
      'q') echo "q 2"; break ;;
      '*') echo "volume 1" ;;
      '/') echo "volume 0" ;;
    esac
  done | build "$1"
else
  if ! test -f ".playlists/$1"
  then
    echo "La playlist $1 n'existe pas."
    exit
  fi
  cat ".playlists/$1" | sort -R | head -n $limit > .playlist && $mplayer -playlist .playlist
  mv -v .playlist /tmp
fi
