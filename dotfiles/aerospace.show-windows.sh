#!/bin/bash
# Show a dialog listing all windows on the focused workspace
LIST=$(aerospace list-windows --workspace focused | awk -F'|' '{
    gsub(/^[ \t]+|[ \t]+$/,"",$2)
    gsub(/^[ \t]+|[ \t]+$/,"",$3)
    printf "%s — %s\\n", $2, $3
}')
[ -z "$LIST" ] && LIST="(no windows)"
osascript -e "display dialog \"$LIST\" with title \"Workspace Windows\" buttons {\"OK\"} default button 1 giving up after 5" &>/dev/null &
