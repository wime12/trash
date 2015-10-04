#!/usr/local/bin/mksh

# trash
# Features:
# Alias fuer 'rm' oder 'del'.
# Verschiebt Dateien in den Papierkorb.
# Innerhalb des Papierkorbs wird richtig geloescht.
# Mit Versionskontrolle

# $trash und $trashlog muessen schreibbar fuer alle sein.

trashdir=/.trash
trashlog=/.trash/trash.log	# Logging endgueltig entfernter Dateien
pwddir=$PWD
datum=`date +'%y/%m/%d %H:%M'`

# Optionen
# --------
if [[ "$1" == "-r" ]] ; then
  recursive="yes"
  shift
fi


# Hauptteil
# ---------

for file in "$@"
do
  # Ziel-Verzeichnis bestimmen
  # --------------------------
  reldir=$(dirname "$file")
  name=$(basename "$file")
  case "$reldir" in
    /*) directory="$reldir" ;;
     .) directory="$pwddir" ;;
     *) directory=$pwddir/$reldir
  esac

  # Zur Sicherheit: Verzeichisse sind nur mittels -r loeschbar
  # ----------------------------------------------------------
  if [ -d "$file" ] && [ "$recursive" != "yes" ] ; then
    echo "$file ist ein Verzeichnis. Verwenden Sie rm -r."
    continue
  fi

  # Verschieben oder Loeschen
  # -------------------------
  if [[ `cd "$directory" 2>/dev/null; pwd` != $trashdir* ]]
  then
    # 2 Versionen erhalten
    if [ -e "$trashdir/$directory/$name" ] ; then
      /bin/rm -r "$trashdir/$directory/$name.1" 2>/dev/null
      mv "$trashdir/$directory/$name" "$trashdir/$directory/$name.1"
    fi
    # In den Trash verschieben
    # ------------------------
    mkdir -p "$trashdir/$directory" 2>/dev/null
    mv "$file" "$trashdir/$directory"
  else
    # Richtiges Loeschen im Trash
    # ---------------------------
    if [ -d "$file" ]
    then /bin/rm -r "$file"
    else /bin/rm "$file"
    fi
    echo "$file entfernt $datum" >> $trashlog
  fi
done
