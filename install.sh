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

# Per-session last-stop timestamps live here (written by the Stop hook,
# read by the statusLine command).
DATA_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/claude-full-statusline"
mkdir -p "$DATA_DIR"

# --- 2) Patch settings.json's statusLine.command --------------------------
# The statusLine command runs claude-hud and appends ` | SessionID: xxxxxxxx`
# and ` | Last: HH:MM · Nm ago` (both dim grey) to the first output line.
read -r -d '' CMD <<'EOF' || true
bash -c 'cols=$(stty size </dev/tty 2>/dev/null | awk '"'"'{print $2}'"'"'); export COLUMNS=$(( ${cols:-120} > 4 ? ${cols:-120} - 4 : 1 )); plugin_dir=$(ls -1d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/claude-hud/*/ 2>/dev/null | sort -V | tail -1); bun_bin=$(command -v bun || echo "$HOME/.bun/bin/bun"); input=$(cat); full_sid=$(printf "%s" "$input" | jq -r ".session_id // empty" 2>/dev/null); sid=$(printf "%s" "$full_sid" | cut -c1-8); ESC=$(printf "\033"); sfx=""; [ -n "$sid" ] && sfx=" ${ESC}[2m| SessionID:${ESC}[0m $sid"; last_file="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/claude-full-statusline/last-stop-$full_sid"; if [ -n "$full_sid" ] && [ -f "$last_file" ]; then ts=$(cat "$last_file" 2>/dev/null); now=$(date +%s); if [ -n "$ts" ]; then diff=$((now - ts)); abs=$(date -d "@$ts" +%H:%M 2>/dev/null || date -r "$ts" +%H:%M 2>/dev/null); if [ "$diff" -lt 60 ]; then rel="${diff}s ago"; elif [ "$diff" -lt 3600 ]; then rel="$((diff/60))m ago"; elif [ "$diff" -lt 86400 ]; then rel="$((diff/3600))h ago"; else rel="$((diff/86400))d ago"; fi; sfx="$sfx ${ESC}[2m| Last:${ESC}[0m $abs ${ESC}[2m·${ESC}[0m $rel"; fi; fi; printf "%s" "$input" | "$bun_bin" --env-file /dev/null "${plugin_dir}src/index.ts" | sed "1 s~\$~$sfx~"'
EOF

# Stop hook: writes the current epoch to a per-session file.
# The trailing comment `# claude-full-statusline-last-stop` is a marker so
# repeat installs replace the existing entry instead of duplicating it.
read -r -d '' STOP_CMD <<'EOF' || true
bash -c 'sid=$(jq -r ".session_id // empty" 2>/dev/null); dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/claude-full-statusline"; [ -n "$sid" ] && mkdir -p "$dir" && date +%s > "$dir/last-stop-$sid"' # claude-full-statusline-last-stop
EOF

SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.bak.$(date +%s)"
  cp "$SETTINGS" "$BACKUP"
  echo "[OK] backup -> $BACKUP"
else
  echo '{}' > "$SETTINGS"
fi

jq --arg cmd "$CMD" --arg stop "$STOP_CMD" '
  .statusLine = {type: "command", command: $cmd}
  | .hooks //= {}
  | .hooks.Stop //= []
  | .hooks.Stop |= map(
      select((.hooks // [])
        | map(.command // "" | contains("claude-full-statusline-last-stop"))
        | any | not)
    )
  | .hooks.Stop += [{matcher: "", hooks: [{type: "command", command: $stop}]}]
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
echo "[OK] statusLine + Stop hook patched in $SETTINGS"

echo
echo "Done. Restart Claude Code to apply."
