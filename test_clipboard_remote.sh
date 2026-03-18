#!/bin/bash
# Run on REMOTE machine to verify clipboard forwarding works.
# Usage: bash test_clipboard_remote.sh

PORT="${1:-2225}"

echo "=== Clipboard Forward Health Check (remote) ==="

# 1. Check if port is listening (SSH reverse forward active)
if ss -tln 2>/dev/null | grep -q ":$PORT "; then
    echo "[OK] Port $PORT is listening (reverse forward active)"
elif netstat -tln 2>/dev/null | grep -q ":$PORT "; then
    echo "[OK] Port $PORT is listening (reverse forward active)"
else
    echo "[FAIL] Port $PORT not listening — reverse forward is not active"
    echo "  Fix: Reconnect SSH with RemoteForward $PORT, or run:"
    echo "    ssh -R $PORT:localhost:$PORT <host>"
    exit 1
fi

# 2. Check SSH_CONNECTION (Emacs uses this to detect remote)
if [ -n "$SSH_CONNECTION" ]; then
    echo "[OK] SSH_CONNECTION is set: $SSH_CONNECTION"
else
    echo "[WARN] SSH_CONNECTION not set — Emacs will use pbcopy path instead of nc"
fi

# 3. Check nc availability and flavor
if command -v nc &>/dev/null; then
    NC_VER=$(nc -h 2>&1 | head -1)
    echo "[OK] nc available: $NC_VER"
else
    echo "[FAIL] nc not found — install netcat"
    exit 1
fi

# 4. Test send
STAMP="clipboard-test-$(date +%s)"
echo "$STAMP" | nc -N localhost "$PORT" 2>/dev/null
NC_EXIT=$?
if [ $NC_EXIT -eq 0 ]; then
    echo "[OK] Sent '$STAMP' to localhost:$PORT (nc exit 0)"
    echo "  -> Check local clipboard (Cmd+V) for: $STAMP"
else
    echo "[FAIL] nc exited with code $NC_EXIT"
    echo "  The forwarded port may not be connected to a listener"
fi

# 5. Check Emacs config
INIT="$HOME/.emacs.d/init.el"
if [ -f "$INIT" ]; then
    if grep -q "interprogram-cut-function" "$INIT"; then
        if grep -q "$PORT" "$INIT"; then
            echo "[OK] Emacs init.el has clipboard function with port $PORT"
        else
            echo "[WARN] Emacs init.el has clipboard function but wrong port (expected $PORT)"
            echo "  Fix: sed -i 's/222[0-9]/$PORT/' $INIT"
        fi
    else
        echo "[FAIL] Emacs init.el missing interprogram-cut-function"
    fi
else
    echo "[WARN] No ~/.emacs.d/init.el found"
fi
