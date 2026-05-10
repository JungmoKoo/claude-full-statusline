# claude-full-statusline

Custom Claude HUD display options, an 8-character SessionID suffix, and the time of the last assistant response — all rendered in dim grey at the end of the statusline's first line.

Example suffix: ` | SessionID: a1b2c3d4 | Last: 14:23 · 3m ago`

This repo customizes the [claude-hud](https://github.com/jarrodwatts/claude-hud) plugin, so you must install claude-hud first. The steps below walk through everything from scratch — follow them in order and you'll be up and running.

## Prerequisites

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

### Step 1 — Install the `claude-hud` plugin

Inside Claude Code, run the following slash commands one by one:

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud@claude-hud
/claude-hud:setup
```

This adds the marketplace, installs the plugin, and runs its setup. The setup step is required before continuing — `install.sh` checks that the plugin is present and will fail otherwise.

### Step 2 — Install this customization

In your shell (outside Claude Code):

```bash
git clone https://github.com/JungmoKoo/claude-full-statusline.git
cd claude-full-statusline
./install.sh
```

When it finishes, restart Claude Code. You should see ` | SessionID: xxxxxxxx | Last: HH:MM · Nm ago` (dim grey) at the end of the statusline's first line. The `Last: ...` segment appears after the first assistant response in the session — it won't show up until then.

## What it changes

- Copies `config.json` to `~/.claude/plugins/claude-hud/config.json` (HUD display options).
- Patches `~/.claude/settings.json` so that:
  - `statusLine.command` runs claude-hud and appends the SessionID + last-response-time suffix.
  - A `Stop` hook writes a per-session timestamp to `~/.claude/claude-full-statusline/last-stop-<sessionid>` after every assistant response. (The hook is tagged with a marker so re-running `install.sh` replaces it instead of duplicating.)

Your existing `settings.json` is automatically backed up to `settings.json.bak.<epoch>`.

## Restore

```bash
ls -t ~/.claude/settings.json.bak.* | head -1 | xargs -I{} cp {} ~/.claude/settings.json
```

## Customize

To change display options, edit `config.json` and re-run `./install.sh`.
