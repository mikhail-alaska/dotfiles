#!/usr/bin/env sh

interface="$(route get default 2>/dev/null | awk '/interface:/ {print $2; exit}')"
ssid=""
if [ -n "$interface" ]; then
    ssid="$(ipconfig getsummary "$interface" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"
fi

if [ -n "$ssid" ]; then
    sketchybar --set "$NAME" icon="󰖩" label="$ssid"
elif [ -n "$interface" ]; then
    sketchybar --set "$NAME" icon="󰈀" label="$interface"
else
    sketchybar --set "$NAME" icon="󰖪" label="offline"
fi
