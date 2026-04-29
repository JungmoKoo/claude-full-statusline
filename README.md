# claude-full-statusline

Custom Claude HUD display options plus an 8-character SessionID suffix (rendered in dim grey) appended to the statusline.

## Prerequisites

- You have run `/claude-hud:setup` once inside Claude Code.
- `jq` and `bun` must be installed.
  - Verify: `command -v jq && command -v bun` (both should print a path)

### Installing dependencies

#### `jq`

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y jq

# macOS (Homebrew)
brew install jq

# Fedora / RHEL
sudo dnf install -y jq

# Arch
sudo pacman -S jq
```

#### `bun`

```bash
curl -fsSL https://bun.sh/install | bash
# After install, open a new shell or apply PATH in the current shell:
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

Verify:

```bash
command -v jq && command -v bun
```

## 🚀 Installation

```bash
git clone https://github.com/JungmoKoo/claude-full-statusline.git
cd claude-full-statusline
./install.sh
```

When it finishes, restart Claude Code. You should see ` | SessionID: xxxxxxxx` (dim grey) at the end of the statusline's first line.

## What it changes

- Copies `config.json` to `~/.claude/plugins/claude-hud/config.json` (HUD display options).
- Patches `~/.claude/settings.json` so that `statusLine.command` runs claude-hud and appends the SessionID suffix.

Your existing `settings.json` is automatically backed up to `settings.json.bak.<epoch>`.

## Restore

```bash
ls -t ~/.claude/settings.json.bak.* | head -1 | xargs -I{} cp {} ~/.claude/settings.json
```

## Customize

To change display options, edit `config.json` and re-run `./install.sh`.
