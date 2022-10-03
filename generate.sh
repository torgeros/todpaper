#! /usr/bin/bash

cd $(dirname "$0")

# find lines start with '#', leading whitespace allowed
commentpattern="\s*#.*"

# find everything that is not part of the time notation
# group 1: cron time settings
# group 3: filename
# group 5: time interval for dir (can be empty)
filterpattern="\s*(([^\s]+\s+){5})([^\s]+)\s*(\s+(\d+)){0,1}$"

#TODO remove old file from crontab
#TODO delete old generated file

while read line; do
    if [[ $line =~ $commentpattern ]]; then
        continue
    fi

    [[ $line =~ $filterpattern ]]
    # get time command
    timecmd="${BASH_REMATCH[1]}"
    # get filename from line
    filename="${BASH_REMATCH[3]}"

    if [ -d $filename ]; then
        # filename is directory
        echo "adding dir  \"$filename\""
        interval="${BASH_REMATCH[5]}"
        if [ "$interval" = "" ]; then
            interval="1800"
        fi
        command="${timecmd}python3 ksetwallpaper/ksetwallpaper.py -d $filename -t $interval"
        echo "-> $command"
    elif [ -f $filename ]; then
        # filename is single file
        echo "adding file \"$filename\""
        command="${timecmd}python3 ksetwallpaper/ksetwallpaper.py --file $filename"
        echo "-> $command"
    else
        # filename does not exist
        echo "file \"$filename\" not found!"
        exit 1
    fi
done < config.txt
