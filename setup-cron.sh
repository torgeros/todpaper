#! /usr/bin/bash

cd $(dirname "$0")

###################################################################################################
# SECTION 1: setup login task

storexdbuscmd="$(pwd)/login-job.sh"

if ! grep -Fxq "$storexdbuscmd" ~/.profile; then
    echo did not find login job in ~/.profile, adding.
    echo "" >> ~/.profile
    echo "$storexdbuscmd" >> ~/.profile
else
    echo login job already registered
fi

###################################################################################################
# SECTION 2: setup cronjob

# generate a pattern for pwd, escaping '/' and '.'
sedpwd=$(echo $(pwd) | sed 's/\//\\\//g' | sed 's/\./\\./g')

applycommand="$(pwd)/apply-current.sh"

sedapplycommand="${sedpwd}\/apply-current\.sh"

# remove all previous commands of this script from the crontab
crontab -l | sed -r "/.+$sedapplycommand.*/d" | crontab -

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
    echo "adding command for \"$filename\""
    echo -e "$(crontab -l)\n$timecmd$applycommand" | crontab -
done < config.txt

echo -e "$(crontab -l)\n$runatboot" | crontab -

###################################################################################################
# SECTION 3: apply config now
./apply-current.sh
