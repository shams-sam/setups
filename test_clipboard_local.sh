#!/bin/bash
# Run on LOCAL machine to verify clipboard listener is healthy.
# Usage: bash test_clipboard_local.sh

PORT="${1:-2225}"

echo "=== Clipboard Listener Health Check (local) ==="

# 1. Check listener
LISTEN_COUNT=$(lsof -i :"$PORT" -sTCP:LISTEN 2>/dev/null | grep -c nc)
if [ "$LISTEN_COUNT" -eq 0 ]; then
    echo "[FAIL] No nc listener on port $PORT"
    echo "  Fix: ~/.local/bin/clipboard-listener $PORT &"
    exit 1
elif [ "$LISTEN_COUNT" -gt 1 ]; then
    echo "[WARN] Multiple nc listeners on port $PORT ($LISTEN_COUNT). Kill extras:"
    lsof -i :"$PORT" -sTCP:LISTEN 2>/dev/null | grep nc
else
    echo "[OK] Listener running on port $PORT"
fi

# 2. Check for VS Code conflict
VSCODE_COUNT=$(lsof -i :"$PORT" -sTCP:LISTEN 2>/dev/null | grep -c "Code")
if [ "$VSCODE_COUNT" -gt 0 ]; then
    echo "[WARN] VS Code is also listening on port $PORT — will conflict!"
    echo "  Fix: Close the auto-forwarded port in VS Code's Ports panel"
else
    echo "[OK] No VS Code conflict"
fi

# 3. Test round-trip
STAMP="clipboard-test-$(date +%s)"
echo "$STAMP" | nc -w1 localhost "$PORT" 2>/dev/null
sleep 0.5
PASTED=$(pbpaste 2>/dev/null)
if [ "$PASTED" = "$STAMP" ]; then
    echo "[OK] Round-trip works — '$STAMP' on clipboard"
else
    echo "[FAIL] Round-trip failed"
    echo "  Sent: $STAMP"
    echo "  Got:  $PASTED"
fi
