# claude-full-statusline

Adds **SessionID** and **last response time** to the Claude Code statusline.

```
... | SessionID: a1b2c3d4 | Last: 14:23 · 3m ago
```

---

## 🚀 Install — 3 steps

### 1️⃣ Install **bun**

**macOS / Linux / WSL / Git Bash on Windows:**

```bash
curl -fsSL https://bun.sh/install | bash
```

**Windows PowerShell:**

```powershell
irm https://bun.sh/install.ps1 | iex
```

> Restart your shell so PATH is refreshed.

### 2️⃣ Install **claude-hud** plugin (inside Claude Code)

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud@claude-hud
/claude-hud:setup
```

### 3️⃣ Install **this customization**

**macOS / Linux / WSL / Git Bash on Windows:**

```bash
curl -fsSL https://raw.githubusercontent.com/JungmoKoo/claude-full-statusline/main/install.sh | bash
```

**Windows PowerShell:**

```powershell
curl.exe -fsSL https://raw.githubusercontent.com/JungmoKoo/claude-full-statusline/main/install.sh -o "$env:TEMP\install.sh"
& "$env:ProgramFiles\Git\bin\bash.exe" "$env:TEMP\install.sh"
```

> ✅ Restart Claude Code. Done.
> Your `~/.claude/settings.json` is auto-backed up to `settings.json.bak.<epoch>`.

---

## 🎨 Customize

```bash
git clone https://github.com/JungmoKoo/claude-full-statusline.git
cd claude-full-statusline
# edit config.json
./install.sh
```

## ↩️ Restore

```bash
ls -t ~/.claude/settings.json.bak.* | head -1 | xargs -I{} cp {} ~/.claude/settings.json
```
