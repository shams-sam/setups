#!/bin/bash
# Cycle focus to the next window on the focused workspace (wraps around)
IDS=$(aerospace list-windows --workspace focused | awk -F'|' '{gsub(/ /,"",$1); print $1}')
[ -z "$IDS" ] && exit 0
CUR=$(aerospace list-windows --focused | awk -F'|' '{gsub(/ /,"",$1); print $1}')
NEXT=$(echo "$IDS" | awk -v c="$CUR" 'found{print; exit} $0==c{found=1}')
[ -z "$NEXT" ] && NEXT=$(echo "$IDS" | head -1)
aerospace focus --window-id "$NEXT"
