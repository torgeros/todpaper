#! /usr/bin/bash

cd $(dirname "$0")

echo applying current config
./apply-current.sh

echo setting up Xdbus file
# https://unix.stackexchange.com/a/111190/243409
touch $(pwd)/Xdbus
chmod 600 $(pwd)/Xdbus
env | grep DBUS_SESSION_BUS_ADDRESS > $(pwd)/Xdbus
echo 'export DBUS_SESSION_BUS_ADDRESS' >> $(pwd)/Xdbus
echo done.
