#!/bin/bash

# Program version
VERSION="v0.2"

# Define colors
COLOR_BLACK="\033[0;30m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_ORANGE="\033[0;33m" 
COLOR_BLUE="\033[0;34m" 
COLOR_PURPLE="\033[0;35m" 
COLOR_CYAN="\033[0;36m" 
COLOR_LIGHT_GRAY="\033[0;37m" 
COLOR_DARK_GRAY="\033[1;30m"
COLOR_LIGHT_RED="\033[1;31m"
COLOR_LIGHT_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_LIGHT_BLUE="\033[1;34m"
COLOR_LIGHT_PURPLE="\033[1;35m"
COLOR_LIGHT_CYAN="\033[1;36m"
COLOR_WHITE="\033[1;37m"

# Define some "special" sequences
COLOR_NONE="\033[0m"
CLEAR_LINE="\033[1K\033[1000D"

########################
# Check for parameters #
########################

if [ "$1" ]; then  # Parameter given?
  if [ "$1" = "--help" ]; then
    echo "Usage: picrenamer [OPTIONS] FILES"
    echo
    echo "picrenamer will take the EXIF date from the pictures and rename the file accordingly."
    echo
    echo "Options"
    echo "--help     This help"
    exit
  fi
fi

##########################
# Check for needed tools #
##########################

NEEDED_TOOLS="mv exiftool awk tr"

for x in $NEEDED_TOOLS; do
  which $x > /dev/null
  if [ $? -ne 0 ]; then
    echo -e "Tool $COLOR_WHITE$x$COLOR_NONE is missing!"
    exit 1
  fi
done

###############
# Starting up #
###############

echo -ne "$COLOR_LIGHT_RED"
echo
echo "       _      ____                                      "
echo " _ __ (_) ___|  _ \ ___ _ __   __ _ _ __ ___   ___ _ __ "
echo "| '_ \| |/ __| |_) / _ \ '_ \ / _\` | '_ \` _ \ / _ \ '__|"
echo "| |_) | | (__|  _ <  __/ | | | (_| | | | | | |  __/ |   "
echo "| .__/|_|\___|_| \_\___|_| |_|\__,_|_| |_| |_|\___|_|   "
echo "|_|                                                     "
echo -e "$COLOR_RED""picRenamer $COLOR_LIGHT_RED$VERSION"
echo -ne "$COLOR_NONE"
echo

################
# Rename Files #
################

FILECOUNT=$#
FILENUM=0
for OLDFILE in "$@"; do
  # Get name parts of old file
  FILENAME="${OLDFILE##*/}"
  DIRECTORY="${OLDFILE:0:${#OLDFILE} - ${#FILENAME}}"
  BASENAME="${OLDFILE%.[^.]*}"
  EXTENSION=$(echo "${OLDFILE:${#BASENAME} + 1}" | tr [:upper:] [:lower:])

  # Get EXIF info and build new name
  EXIFDATE=$(exiftool -CreateDate -d "%Y-%m-%d %H.%M.%S" "$OLDFILE" 2>/dev/null | awk '{print $4 " " $5}')
  NEWFILE="$DIRECTORY$EXIFDATE.$EXTENSION"

  # Add number for same filenames
  NUM=1
  while [ -e "$NEWFILE" ]; do
    if [ "$OLDFILE" != "$NEWFILE" ]; then
        NUM=$((NUM+1))
        NEWFILE="$DIRECTORY$EXIFDATE ($NUM).$EXTENSION"
    else
      break
    fi
  done
  
  # Handle file renaming
  FILENUM=$((FILENUM+1))
  echo -ne "$COLOR_YELLOW[$FILENUM/$FILECOUNT]$COLOR_NONE "
  if [ "$EXIFDATE" != "" ]; then
    if [ "$EXIFDATE" != "0000:00:00 00:00:00" ]; then
      if [ "$OLDFILE" != "$NEWFILE" ]; then
        echo -e "Renaming $COLOR_WHITE'"$(basename "$OLDFILE")"'$COLOR_NONE to $COLOR_WHITE'"$(basename "$NEWFILE")"'$COLOR_NONE"
        mv -n "$OLDFILE" "$NEWFILE"  # -n -> do not overwrite an existing file
        touch "$NEWFILE"             # Update timestamp
      else
        echo -e "$COLOR_WHITE'"$(basename "$OLDFILE")"'$COLOR_NONE has already the correct name!"
      fi
    else
      echo -e "$COLOR_WHITE'"$(basename "$OLDFILE")"'$COLOR_LIGHT_RED has a bad EXIF Date!$COLOR_NONE"
    fi
  else
    echo -e "$COLOR_WHITE'"$(basename "$OLDFILE")"'$COLOR_LIGHT_RED has no EXIF Date!$COLOR_NONE"
  fi
done

# We're done...
echo "done..."
