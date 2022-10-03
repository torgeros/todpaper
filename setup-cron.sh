#! /usr/bin/bash

cd $(dirname "$0")

# generate a pattern for pwd, escaping '/' and '.'
sedpwd=$(echo $(pwd) | sed 's/\//\\\//g' | sed 's/\./\\./g')

commandstem="python3 $(pwd)/ksetwallpaper/ksetwallpaper.py"

sedcmdstem="python3 ${sedpwd}\/ksetwallpaper\/ksetwallpaper\.py"

# command to set current wallpaper at boot in the case the last boot was in a different time section
runatboot="@reboot $(pwd)/apply-current.sh"

sedrunatboot="@reboot ${sedpwd}\/apply-current\.sh"

# remove all previous commands of this script from the crontab
crontab -l | sed -r "/.+$sedcmdstem.*/d" | crontab -
crontab -l | sed -r "/$sedrunatboot/d" | crontab -

# find lines start with '#', leading whitespace allowed
commentpattern='[[:space:]]*#.*'

# find everything that is not part of the time notation
# group 1: cron time settings
# group 3: filename
# 
# in a normal regex, [^[:space:]] could be subbed with [^\s]
#                and [[:space:]] with \s
filterpattern='[[:space:]]*(([^[:space:]]+[[:space:]]+){5})([^[:space:]]+)[[:space:]]*'

while read line; do
    if [[ $line =~ $commentpattern ]]; then
        continue
    fi

    [[ $line =~ $filterpattern ]]
    # get time command, reduce whitespaces
    timecmd=$(echo "${BASH_REMATCH[1]}" | sed -r 's/\s+/ /g' | sed 's/^ //')
    # get filename from line
    filename="${BASH_REMATCH[3]}"

    if [ -d $filename ]; then
        # filename is directory
        echo "directories are not supported"
        exit 1
    elif [ -f $filename ]; then
        # filename is single file
        echo "adding file \"$filename\""
        command="${timecmd}$commandstem --file $filename"
        echo -e "$(crontab -l)\n$command" | crontab -
    else
        # filename does not exist
        echo "file \"$filename\" not found!"
        exit 1
    fi
done < config.txt

echo -e "$(crontab -l)\n$runatboot" | crontab -
./apply-current.sh
