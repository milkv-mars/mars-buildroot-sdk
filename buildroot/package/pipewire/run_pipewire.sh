#!/bin/sh
mkdir -p /run/pipewire
export XDG_RUNTIME_DIR=/run/pipewire
start-stop-daemon -K -s 9 -x pipewire
start-stop-daemon -Sb -q -x dbus-run-session -- pipewire
sleep 2s
echo "Record 10s audio to pwtest.wav now ..."
rm -f pwtest.wav
pw-record pwtest.wav &
sleep 10s
killall pw-record
echo "Stop record and play it again."
pw-play pwtest.wav
start-stop-daemon -K -x pipewire
