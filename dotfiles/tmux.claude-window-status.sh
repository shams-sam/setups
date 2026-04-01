#!/bin/bash
# Global Claude Code state detector + window renamer.
# Called from status-right via #() every status-interval.
# 1. Detects claude processes and idle state for ALL panes (even non-visible)
# 2. Writes state files for pane-border-format to read
# 3. Renames windows with per-pane icons: ⚡✋⚡claude

STATE_DIR="/tmp/tmux-claude-status"
mkdir -p "$STATE_DIR"

# Cross-platform md5: macOS uses md5 -q, Linux uses md5sum
if command -v md5 &>/dev/null; then
    md5cmd() { md5 -q; }
else
    md5cmd() { md5sum | cut -d' ' -f1; }
fi

# Get full process table once
PROCS=$(ps -eo pid,ppid,command 2>/dev/null)

for WIN in $(tmux list-windows -a -F '#{window_id}' 2>/dev/null); do
    WNAME=$(tmux display-message -t "$WIN" -p '#{window_name}' 2>/dev/null)
    ICONS=""

    for PANE_INFO in $(tmux list-panes -t "$WIN" -F '#{pane_id}:#{pane_pid}' 2>/dev/null); do
        PANE_ID="${PANE_INFO%%:*}"
        PANE_PID="${PANE_INFO##*:}"
        PANE_KEY="${PANE_ID//%/}"
        HASH_FILE="$STATE_DIR/${PANE_KEY}.hash"
        COUNT_FILE="$STATE_DIR/${PANE_KEY}.count"
        STATE_FILE="$STATE_DIR/${PANE_KEY}.state"

        # Check process subtree for claude
        HAS_CLAUDE=0
        if echo "$PROCS" | \
           awk -v root="$PANE_PID" 'BEGIN{p[root]=1} $2 in p {p[$1]=1; print $0}' | \
           grep -q claude; then
            HAS_CLAUDE=1
        fi

        if [ "$HAS_CLAUDE" -eq 0 ]; then
            rm -f "$HASH_FILE" "$COUNT_FILE" "$STATE_FILE" 2>/dev/null
            continue
        fi

        # Claude found — capture pane content
        PANE_CONTENT=$(tmux capture-pane -t "$PANE_ID" -p -S -5 2>/dev/null)

        # Check if Claude is actively working (tool/MCP call in progress)
        # "esc to interrupt" appears at the bottom when Claude is running,
        # "? for shortcuts" appears when waiting for user input.
        ACTIVELY_WORKING=0
        if echo "$PANE_CONTENT" | grep -q "esc to interrupt"; then
            ACTIVELY_WORKING=1
        fi

        # Hash pane content for change detection
        CURRENT_HASH=$(echo "$PANE_CONTENT" | md5cmd)
        PREV_HASH=""
        [ -f "$HASH_FILE" ] && PREV_HASH=$(cat "$HASH_FILE")
        echo "$CURRENT_HASH" > "$HASH_FILE"

        if [ "$ACTIVELY_WORKING" -eq 1 ]; then
            # Claude is running a tool/MCP — always active
            echo "1" > "$COUNT_FILE"
            echo "active" > "$STATE_FILE"
            ICONS="${ICONS}⚡"
        elif [ "$CURRENT_HASH" = "$PREV_HASH" ]; then
            # Hash stable — increment counter, only idle after 2 consecutive
            COUNT=1
            [ -f "$COUNT_FILE" ] && COUNT=$(head -1 "$COUNT_FILE")
            [[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=1
            COUNT=$((COUNT + 1))
            echo "$COUNT" > "$COUNT_FILE"
            if [ "$COUNT" -ge 2 ]; then
                echo "idle" > "$STATE_FILE"
                ICONS="${ICONS}✋"
            else
                echo "active" > "$STATE_FILE"
                ICONS="${ICONS}⚡"
            fi
        else
            # Hash changed — reset counter, immediately active
            echo "1" > "$COUNT_FILE"
            echo "active" > "$STATE_FILE"
            ICONS="${ICONS}⚡"
        fi
    done

    # Strip existing icon prefix and apply new one
    CLEAN=$(echo "$WNAME" | sed 's/^[✋⚡]*//')
    DESIRED="${ICONS}${CLEAN}"
    [ "$WNAME" != "$DESIRED" ] && tmux rename-window -t "$WIN" "$DESIRED"
done
