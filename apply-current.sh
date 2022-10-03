#! /usr/bin/bash

cd $(dirname "$0")

commandstem="python3 $(pwd)/ksetwallpaper/ksetwallpaper.py"

# find lines start with '#', leading whitespace allowed
commentpattern='[[:space:]]*#.*'

# find everything that is not part of the time notation
# group 1: cron time settings
# group 3: filename
# 
# in a normal regex, [^[:space:]] could be subbed with [^\s]
#                and [[:space:]] with \s
filterpattern='[[:space:]]*(([^[:space:]]+[[:space:]]+){5})([^[:space:]]+)[[:space:]]*'

latesttimestamp="0"
commandtorun="echo NO LATEST COMMAND FOUND"

while read line; do
    if [[ $line =~ $commentpattern ]]; then
        continue
    fi

    [[ $line =~ $filterpattern ]]
    # get time command, reduce whitespaces
    timecmd=$(echo "${BASH_REMATCH[1]}" | sed -r 's/\s+/ /g' | sed 's/^ //' | sed 's/ $//')
    # get filename from line
    filename="${BASH_REMATCH[3]}"

    # generate latest matching timestamp from timecmd
    year=$(date +"%Y")
    month=$(date +"%m")
    dayofmonth=$(date +"%d")
    hour=$(date +"%H") #24h format
    minute=$(date +"%M")
    IFS=' '
    read -ra timecmdarr <<< "$timecmd"
    # minute
    if [ "${timecmdarr[0]}" != "*" ]; then
        minute=${timecmdarr[0]}
    fi
    # hour
    if [ "${timecmdarr[1]}" != "*" ]; then
        hour=${timecmdarr[1]}
    fi
    # dayofmonth
    if [ "${timecmdarr[2]}" != "*" ]; then
        dayofmonth=${timecmdarr[2]}
    fi
    # month
    if [ "${timecmdarr[3]}" != "*" ]; then
        month=${timecmdarr[3]}
    fi

    # if timestamp has yet to happen in this year, reduce year by one
    if [ $(date --date="$year-$month-${dayofmonth}T$hour:$minute" +"%s") -gt $(date +"%s") ]; then
        year=$(($year - 1))
    fi
    timestamp=$(date --date="$year-$month-${dayofmonth}T$hour:$minute" +"%s")

    if [ $timestamp -le $latesttimestamp ]; then
        continue
    fi
    latesttimestamp=$timestamp

    if [ -d $filename ]; then
        # filename is directory
        echo "directories are not supported"
        exit 1
    elif [ -f $filename ]; then
        # filename is single file
        commandtorun="$commandstem --file $filename"
    else
        # filename does not exist
        echo "file \"$filename\" not found!"
        exit 1
    fi
done < config.txt

$commandtorun
echo done.
