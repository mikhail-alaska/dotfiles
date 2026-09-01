#!/usr/bin/env sh

status="$(pmset -g batt)"
percent="$(printf '%s\n' "$status" | awk 'match($0, /[0-9]+%/) {print substr($0, RSTART, RLENGTH - 1); exit}')"
case "$percent" in
    ''|*[!0-9]*) percent=0 ;;
esac
case "$status" in
    *AC\ Power*|*charging*) icon="󰂄" ;;
    *)
        if [ "${percent:-0}" -lt 20 ]; then icon="󰂃"
        elif [ "${percent:-0}" -lt 50 ]; then icon="󰁾"
        elif [ "${percent:-0}" -lt 80 ]; then icon="󰂀"
        else icon="󰁹"
        fi
        ;;
esac

sketchybar --set "$NAME" icon="$icon" label="${percent}%"
