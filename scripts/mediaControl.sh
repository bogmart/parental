#!/bin/bash

userLoggedIn=$(who | grep tty | awk '{print $1}')

export DISPLAY=:0.0
export XAUTHORITY=/home/${userLoggedIn}/.Xauthority


amixer -q set Speaker unmute

## restore the microphone state
amixer -q set Capture cap

## un-mute bluetooth
# pactl set-sink-mute @DEFAULT_SINK@ 0

