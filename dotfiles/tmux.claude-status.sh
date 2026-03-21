#!/bin/bash
# Per-pane Claude Code status display for tmux pane-border-format.
# Just reads state files written by claude-window-status.sh.
# Args: pane_id
# Output: "✋" if idle, "⚡" if active, empty if no claude.

PANE_ID="$1"
STATE_FILE="/tmp/tmux-claude-status/${PANE_ID//%/}.state"

if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
    if [ "$STATE" = "idle" ]; then
        echo "✋"
    elif [ "$STATE" = "active" ]; then
        echo "⚡"
    fi
fi
