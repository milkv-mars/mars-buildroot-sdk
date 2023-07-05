#!/bin/sh
export XDG_RUNTIME_DIR=/root
export LANG="en_US.UTF-8"
export XCOMPOSEFILE=/root/.config/XCompose
weston --tty=1
