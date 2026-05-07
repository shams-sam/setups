#!/usr/bin/env bash
# Claude Code status line — mirrors agnoster-light prompt
# Receives JSON on stdin from Claude Code

input=$(cat)

# Write dashboard port for tmux pane border display
if [ -n "$APPLE_CLAUDE_CODE_PORT" ] && [ -n "$TMUX_PANE" ]; then
    _pkey="${TMUX_PANE//%/}"
    mkdir -p /tmp/tmux-claude-status
    echo "$APPLE_CLAUDE_CODE_PORT" > "/tmp/tmux-claude-status/${_pkey}.port"
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
conda_env=$(echo "$input" | jq -r 'if .workspace.current_dir then empty else empty end // empty')

# Conda env from environment (not in JSON), fall back gracefully
conda_env="${CONDA_DEFAULT_ENV:-}"

# Git branch (skip optional lock with -c core.checkStat=false)
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.checkStat=false symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Dirty check
  if ! git -C "$cwd" -c core.checkStat=false diff --quiet 2>/dev/null \
    || ! git -C "$cwd" -c core.checkStat=false diff --cached --quiet 2>/dev/null; then
    git_branch="${git_branch} ●"
  fi
fi

# Context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Detect worktree
worktree=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  wt_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  git_common=$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)
  git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
  # If git-dir differs from common-dir, we're in a worktree
  if [ -n "$git_common" ] && [ -n "$git_dir" ]; then
    abs_common=$(cd "$cwd" && cd "$git_common" && pwd)
    abs_git=$(cd "$cwd" && cd "$git_dir" && pwd)
    if [ "$abs_common" != "$abs_git" ]; then
      worktree=$(basename "$wt_root")
    fi
  fi
fi

# Context usage badge (color-coded by percentage)
ctx_badge=""
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if [ "$pct_int" -gt 80 ]; then
    ctx_badge="$(printf '\033[30;41m %s%% \033[0m' "$pct_int")"
  elif [ "$pct_int" -gt 50 ]; then
    ctx_badge="$(printf '\033[30;43m %s%% \033[0m' "$pct_int")"
  else
    ctx_badge="$(printf '\033[30;100m %s%% \033[0m' "$pct_int")"
  fi
fi

# Build output: model | conda | cwd | worktree | git | ctx bar
out=""

if [ -n "$cwd" ]; then
  parent=$(basename "$(dirname "$cwd")")
  leaf=$(basename "$cwd")
  short_cwd="${parent}/${leaf}"
  out="${out} $(printf '\033[30;44m %s \033[0m' "$short_cwd")"
fi

if [ -n "$worktree" ]; then
  out="${out} $(printf '\033[30;41m %s \033[0m' "$worktree")"
fi

if [ -n "$git_branch" ]; then
  out="${out} $(printf '\033[30;43m %s \033[0m' "$git_branch")"
fi

if [ -n "$ctx_badge" ]; then
  out="${out}  ${ctx_badge}"
fi

# Session ID badge (black text on pink background)
session_id=$(echo "$input" | jq -r '.session_id // empty')
if [ -n "$session_id" ]; then
  out="${out}  $(printf '\033[30;105m %s \033[0m' "$session_id")"
fi

printf '%s\n' "$out"
