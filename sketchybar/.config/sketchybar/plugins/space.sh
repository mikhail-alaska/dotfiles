#!/usr/bin/env sh

if [ "${SELECTED:-false}" = "true" ]; then
    sketchybar --set "$NAME" \
        background.color=0xffcba6f7 \
        icon.color=0xff11111b
else
    sketchybar --set "$NAME" \
        background.color=0xff313244 \
        icon.color=0xffcdd6f4
fi
