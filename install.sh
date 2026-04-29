#!/usr/bin/env bash
set -euo pipefail

# Resolve the directory this script lives in (so it works no matter where you run it from)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Sanity checks --------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required but not installed." >&2
  echo "  Install: sudo apt install jq   (or: brew install jq)" >&2
  exit 1
fi
if ! command -v bun >/dev/null 2>&1 && [ ! -x "$HOME/.bun/bin/bun" ]; then
  echo "Error: 'bun' is required (in PATH or at \$HOME/.bun/bin/bun)." >&2
  echo "  Install: curl -fsSL https://bun.sh/install | bash" >&2
  exit 1
fi
if ! ls -1d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/claude-hud/*/ >/dev/null 2>&1; then
  echo "Error: claude-hud plugin not found." >&2
  echo "  Run '/claude-hud:setup' inside Claude Code first." >&2
  exit 1
fi

# --- 1) Place HUD display config ------------------------------------------
HUD_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/claude-hud"
mkdir -p "$HUD_DIR"
cp "$SCRIPT_DIR/config.json" "$HUD_DIR/config.json"
echo "[OK] config.json -> $HUD_DIR/config.json"

# --- 2) Patch settings.json's statusLine.command --------------------------
# The statusLine command runs claude-hud and then appends an 8-char SessionID
# (dim grey) to the first output line via sed.
read -r -d '' CMD <<'EOF' || true
bash -c 'cols=$(stty size </dev/tty 2>/dev/null | awk '"'"'{print $2}'"'"'); export COLUMNS=$(( ${cols:-120} > 4 ? ${cols:-120} - 4 : 1 )); plugin_dir=$(ls -1d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/claude-hud/*/ 2>/dev/null | sort -V | tail -1); bun_bin=$(command -v bun || echo "$HOME/.bun/bin/bun"); input=$(cat); sid=$(printf "%s" "$input" | jq -r ".session_id // empty" 2>/dev/null | cut -c1-8); ESC=$(printf "\033"); sfx=""; [ -n "$sid" ] && sfx=" ${ESC}[2m| SessionID:${ESC}[0m $sid"; printf "%s" "$input" | "$bun_bin" --env-file /dev/null "${plugin_dir}src/index.ts" | sed "1 s~\$~$sfx~"'
EOF

SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.bak.$(date +%s)"
  cp "$SETTINGS" "$BACKUP"
  echo "[OK] backup -> $BACKUP"
else
  echo '{}' > "$SETTINGS"
fi

jq --arg cmd "$CMD" '.statusLine = {type: "command", command: $cmd}' "$SETTINGS" \
  > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
echo "[OK] statusLine patched in $SETTINGS"

echo
echo "Done. Restart Claude Code to apply."
