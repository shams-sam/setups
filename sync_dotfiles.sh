#!/bin/bash
# sync_dotfiles.sh — Sync dotfiles between repo and home (multi-machine)
#
# Usage:
#   ./sync_dotfiles.sh out          Copy home → repo (export current state)
#   ./sync_dotfiles.sh in           Copy repo → home (apply stored dotfiles)
#   ./sync_dotfiles.sh diff         Show differences between repo and home
#   ./sync_dotfiles.sh link         Symlink home → repo (live sync)
#   ./sync_dotfiles.sh unlink       Replace symlinks with copies
#
# Multi-machine:
#   Files target an OS via TARGETS array: "all", "macos", or "linux".
#   Machine-specific variants override the base file:
#     dotfiles/.zshrc.macos  takes priority over  dotfiles/.zshrc  on macOS
#     dotfiles/.tmux.conf.linux  takes priority over  dotfiles/.tmux.conf  on Linux
#   When exporting (out), the current machine's file is written to the variant.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Detect OS: "macos" or "linux"
case "$(uname -s)" in
    Darwin) THIS_OS="macos" ;;
    Linux)  THIS_OS="linux" ;;
    *)      echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

# Mapping: parallel arrays — repo name, home path, target OS
REPO_NAMES=(
    ".aerospace.toml"
    ".tmux.conf"
    "emacs.init.el"
    ".vimrc"
    ".zshrc"
    "agnoster-light.zsh-theme"
)
HOME_PATHS=(
    "$HOME/.aerospace.toml"
    "$HOME/.tmux.conf"
    "$HOME/.emacs.d/init.el"
    "$HOME/.vimrc"
    "$HOME/.zshrc"
    "$HOME/.oh-my-zsh/themes/agnoster-light.zsh-theme"
)
TARGETS=(
    "macos"
    "all"
    "all"
    "linux"
    "all"
    "all"
)

COUNT=${#REPO_NAMES[@]}

usage() {
    sed -n '2,15p' "$0" | sed 's/^# \?//'
    exit 1
}

# Resolve which repo file to use for a given index.
# Prefers OS-specific variant (e.g. .zshrc.macos) over base (.zshrc).
resolve_repo_path() {
    local repo_name="$1"
    local variant="$DOTFILES_DIR/${repo_name}.${THIS_OS}"
    local base="$DOTFILES_DIR/$repo_name"
    if [ -f "$variant" ]; then
        echo "$variant"
    else
        echo "$base"
    fi
}

# Check if a file's target OS matches the current machine
os_match() {
    local target="$1"
    [ "$target" = "all" ] || [ "$target" = "$THIS_OS" ]
}

sync_out() {
    echo "==> Exporting home → repo  [OS: $THIS_OS]"
    for ((i=0; i<COUNT; i++)); do
        repo_name="${REPO_NAMES[$i]}"
        home_path="${HOME_PATHS[$i]}"
        target="${TARGETS[$i]}"
        if ! os_match "$target"; then
            echo "  SKIP dotfiles/$repo_name (target=$target, this=$THIS_OS)"
            continue
        fi
        if [ ! -f "$home_path" ]; then
            echo "  SKIP $home_path (not found)"
            continue
        fi
        # If a variant already exists for another OS, write to our OS variant.
        # If no variants exist, write to the base file.
        other_os=$( [ "$THIS_OS" = "macos" ] && echo "linux" || echo "macos" )
        if [ -f "$DOTFILES_DIR/${repo_name}.${other_os}" ]; then
            dest="$DOTFILES_DIR/${repo_name}.${THIS_OS}"
        else
            dest="$DOTFILES_DIR/$repo_name"
        fi
        cp "$home_path" "$dest"
        echo "  $home_path → dotfiles/$(basename "$dest")"
    done
    echo "Done. Review changes with: cd setups && git diff dotfiles/"
}

sync_in() {
    echo "==> Applying repo → home  [OS: $THIS_OS]"
    for ((i=0; i<COUNT; i++)); do
        repo_name="${REPO_NAMES[$i]}"
        home_path="${HOME_PATHS[$i]}"
        target="${TARGETS[$i]}"
        if ! os_match "$target"; then
            continue
        fi
        repo_path="$(resolve_repo_path "$repo_name")"
        if [ ! -f "$repo_path" ]; then
            echo "  SKIP dotfiles/$repo_name (not in repo)"
            continue
        fi
        if [ -L "$home_path" ]; then
            echo "  SKIP $home_path (already symlinked)"
            continue
        fi
        if [ -f "$home_path" ]; then
            if diff -q "$repo_path" "$home_path" > /dev/null 2>&1; then
                echo "  OK   $home_path (identical)"
                continue
            fi
            echo "  OVERWRITE $home_path"
        else
            mkdir -p "$(dirname "$home_path")"
            echo "  CREATE $home_path"
        fi
        cp "$repo_path" "$home_path"
    done
    echo "Done."
}

sync_diff() {
    local has_diff=0
    echo "[OS: $THIS_OS]"
    for ((i=0; i<COUNT; i++)); do
        repo_name="${REPO_NAMES[$i]}"
        home_path="${HOME_PATHS[$i]}"
        target="${TARGETS[$i]}"
        if ! os_match "$target"; then
            continue
        fi
        repo_path="$(resolve_repo_path "$repo_name")"
        if [ ! -f "$repo_path" ]; then
            if [ -f "$home_path" ]; then
                echo "--- dotfiles/$repo_name missing (exists at $home_path)"
                has_diff=1
            fi
            continue
        fi
        if [ ! -f "$home_path" ]; then
            echo "--- $home_path missing (exists in repo as dotfiles/$(basename "$repo_path"))"
            has_diff=1
            continue
        fi
        if ! diff -q "$repo_path" "$home_path" > /dev/null 2>&1; then
            echo "=== $(basename "$repo_path") ==="
            diff --color=auto -u \
                --label "repo: dotfiles/$(basename "$repo_path")" \
                --label "home: $home_path" \
                "$repo_path" "$home_path" || true
            has_diff=1
        fi
    done
    [ $has_diff -eq 0 ] && echo "All dotfiles in sync."
}

sync_link() {
    echo "==> Symlinking home → repo  [OS: $THIS_OS]"
    for ((i=0; i<COUNT; i++)); do
        repo_name="${REPO_NAMES[$i]}"
        home_path="${HOME_PATHS[$i]}"
        target="${TARGETS[$i]}"
        if ! os_match "$target"; then
            continue
        fi
        repo_path="$(resolve_repo_path "$repo_name")"
        if [ ! -f "$repo_path" ]; then
            echo "  SKIP dotfiles/$repo_name (not in repo — run 'out' first)"
            continue
        fi
        if [ -L "$home_path" ]; then
            echo "  OK   $home_path (already linked)"
            continue
        fi
        if [ -f "$home_path" ]; then
            mv "$home_path" "${home_path}.bak"
            echo "  BACKUP ${home_path}.bak"
        else
            mkdir -p "$(dirname "$home_path")"
        fi
        ln -s "$repo_path" "$home_path"
        echo "  LINK $home_path → dotfiles/$(basename "$repo_path")"
    done
    echo "Done. Edits to either path now hit the same file."
}

sync_unlink() {
    echo "==> Replacing symlinks with copies  [OS: $THIS_OS]"
    for ((i=0; i<COUNT; i++)); do
        repo_name="${REPO_NAMES[$i]}"
        home_path="${HOME_PATHS[$i]}"
        target="${TARGETS[$i]}"
        if ! os_match "$target"; then
            continue
        fi
        repo_path="$(resolve_repo_path "$repo_name")"
        if [ -L "$home_path" ]; then
            rm "$home_path"
            cp "$repo_path" "$home_path"
            echo "  COPY $home_path (was symlink)"
        fi
    done
    echo "Done."
}

case "${1:-}" in
    out)    sync_out ;;
    in)     sync_in ;;
    diff)   sync_diff ;;
    link)   sync_link ;;
    unlink) sync_unlink ;;
    *)      usage ;;
esac
