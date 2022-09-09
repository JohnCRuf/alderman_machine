#!/bin/bash
echo "THE TIME SPAN OF EACH TASK IS PRINTED AS FOLLOWS:"
DIRS=$(ls -d */output)

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

for DIR in ${DIRS}
do
  if ! [ -z "$(ls $DIR)" ] ; then
    LATEST=$(stat -f "%m" $DIR/* | sort -rn | head -1)
    EARLIEST=$(stat -f "%m" $DIR/* | sort -rn | tail -1)
    TIME_DIFF=$(($LATEST-$EARLIEST))
    echo "$DIR: $(displaytime ${TIME_DIFF})"
  fi
done