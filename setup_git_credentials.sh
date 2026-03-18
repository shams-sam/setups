#!/bin/bash
# Setup git credential store and VS Code stale socket guard
#
# Usage: bash setup_git_credentials.sh
#
# What this does:
# 1. Configures git credential.helper store (~/.git-credentials, plaintext)
# 2. Adds a guard to ~/.bashrc and ~/.profile that unsets stale VS Code
#    git credential env vars (prevents ECONNREFUSED on dead socket)
# 3. After running, do a `git push` — enter your GitHub PAT as the password
#    and it will be saved permanently.
#
# To generate a GitHub PAT:
#   GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
#   Scope: repo

set -e

# 1. Set credential helper
if [ "$(git config --global credential.helper)" = "store" ]; then
    echo "[ok] credential.helper already set to store"
else
    git config --global credential.helper store
    echo "[set] credential.helper = store"
fi

# 2. Add stale VS Code socket guard
GUARD='# Guard against stale VS Code git credential socket
if [ -n "$VSCODE_GIT_IPC_HANDLE" ] && [ ! -S "$VSCODE_GIT_IPC_HANDLE" ]; then
  unset GIT_ASKPASS VSCODE_GIT_IPC_HANDLE VSCODE_GIT_ASKPASS_NODE VSCODE_GIT_ASKPASS_MAIN
fi'

MARKER="Guard against stale VS Code git credential socket"

for rcfile in ~/.bashrc ~/.profile; do
    if [ -f "$rcfile" ]; then
        if grep -q "$MARKER" "$rcfile"; then
            echo "[ok] guard already in $rcfile"
        else
            echo "" >> "$rcfile"
            echo "$GUARD" >> "$rcfile"
            echo "[added] guard to $rcfile"
        fi
    fi
done

echo ""
echo "Done. Next steps:"
echo "  1. source ~/.bashrc  (or open a new terminal)"
echo "  2. git push — enter your GitHub PAT as password (it will be saved)"
