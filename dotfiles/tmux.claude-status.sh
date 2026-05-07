#!/bin/bash
# Per-pane Claude Code status display for tmux pane-border-format.
# Just reads state files written by claude-window-status.sh.
# Port file written by Claude Code's statusline-command.sh.
# Args: pane_id
# Output: "✋ localhost:PORT" if idle, "⚡ localhost:PORT" if active, empty if no claude.

PANE_ID="$1"
PANE_KEY="${PANE_ID//%/}"
STATE_FILE="/tmp/tmux-claude-status/${PANE_KEY}.state"
PORT_FILE="/tmp/tmux-claude-status/${PANE_KEY}.port"

if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
    ICON=""
    [ "$STATE" = "idle" ] && ICON="✋"
    [ "$STATE" = "active" ] && ICON="⚡"

    if [ -n "$ICON" ]; then
        if [ -f "$PORT_FILE" ]; then
            echo "$ICON http://localhost:$(cat "$PORT_FILE")"
        else
            echo "$ICON"
        fi
    fi
fi
