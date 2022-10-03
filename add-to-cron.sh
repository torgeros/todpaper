#! /usr/bin/bash

cd $(dirname "$0")

commandstem="python3 ksetwallpaper/ksetwallpaper.py"

# escaped '/' and '.'
sedcmdstem="python3 ksetwallpaper\/ksetwallpaper\.py"

# remove all previous commands of this script from the crontab
crontab -l | sed -r "/.+$sedcmdstem.*/d" | crontab -

# find lines start with '#', leading whitespace allowed
commentpattern="\s*#.*"

# find everything that is not part of the time notation
# group 1: cron time settings
# group 3: filename
# group 5: time interval for dir (can be empty)
filterpattern="\s*(([^\s]+\s+){5})([^\s]+)\s*(\s+(\d+)){0,1}$"

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
        command="${timecmd}$commandstem -d $filename -t $interval"
        echo -e "$(crontab -l)\n$command" | crontab -
    elif [ -f $filename ]; then
        # filename is single file
        echo "adding file \"$filename\""
        command="${timecmd}$commandstem --file $filename"
        echo "$(crontab -l)\n$command" | crontab -
    else
        # filename does not exist
        echo "file \"$filename\" not found!"
        exit 1
    fi
done < config.txt
