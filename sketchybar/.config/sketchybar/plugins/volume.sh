#!/usr/bin/env sh

volume="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || printf '0')"
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || printf 'false')"
case "$volume" in
    ''|*[!0-9]*) volume=0 ;;
esac

if [ "$muted" = "true" ] || [ "$volume" -eq 0 ]; then
    icon="󰝟"
elif [ "$volume" -lt 34 ]; then
    icon="󰕿"
elif [ "$volume" -lt 67 ]; then
    icon="󰖀"
else
    icon="󰕾"
fi

sketchybar --set "$NAME" icon="$icon" label="${volume}%"
