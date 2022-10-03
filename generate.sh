#! /usr/bin/bash

cd $(dirname "$0")

# find lines start with '#', leading whitespace allowed
commentpattern="\s*#.*"

# find everything that is not part of the time notation
# group 1: cron time settings
# group 3: filename
# group 5: time interval for dir (can be empty)
filterpattern="\s*(([^\s]+\s+){5})([^\s]+)\s*(\s+(\d+)){0,1}"

#TODO remove old file from crontab
#TODO delete old generated file

while read line; do
    if [[ $line =~ $commentpattern ]]; then
        continue
    fi
    # get filename from line
    [[ $line =~ $filterpattern ]]
    filename="${BASH_REMATCH[3]}"

    if [ -d $filename ]; then
        echo "adding dir  \"$filename\""
        interval="${BASH_REMATCH[5]}"
        if [ "$interval" = "" ]; then
            interval="1800"
        fi
        command="python3 ksetwallpaper/ksetwallpaper.py -d $filename -t $interval"
        echo "-> $command"
    elif [ -f $filename ]; then
        echo "adding file \"$filename\""
        command="python3 ksetwallpaper/ksetwallpaper.py --file $filename"
        echo "-> $command"
    else
        echo "file \"$filename\" not found!"
        exit 1
    fi
done < config.txt
