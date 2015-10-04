#!/bin/mksh

# emptytrash
# Regelmaessig von cron ausfuehren lassen.
# Leert die Trash-Verzeichnisse, wenn sie die Maximalgroesse uebersteigen.

trashlog=/.trash/trash.log	# entfernte Dateien loggen
datum=$(date +'%y/%m/%d %H:%M')
tmpfile=/tmp/emptytrash.tmp

# Maximalgroessen in Bytes
maxsizes=" /.trash       50000000 
	   /usr/.trash   50000000 
	   /home/.trash 100000000 
	   /var/.trash   50000000 "

echo "$maxsizes" |

# Schleife um Trash-Verzeichnisse
while read trash maxsize
do

  realsize=`du -sx $trash | awk '{print $1}'`
  realsize=$((realsize*1024))			# jetzt in Bytes

  find "$trash" -print0 | xargs -0 ls -ldtr > "$tmpfile" # zeitlich sortiert
  while (( $realsize > $maxsize )) && read x x x x fsize x x x file
  do
    [ "$file" == "$trashlog" ] && continue
    ((realsize-=$fsize))
    if [ -d "$file" ]
    then rmdir "$file" 2> /dev/null
    else rm "$file"    2> /dev/null
    fi
    [ "$?" == "0" ] && echo "$file" "entfernt $datum" >> $trashlog
  done <"$tmpfile"

done
