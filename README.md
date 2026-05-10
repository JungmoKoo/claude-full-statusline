# claude-full-statusline

Adds **SessionID** and **last response time** to the Claude Code statusline.

```
... | SessionID: a1b2c3d4 | Last: 2026-05-10 16:02:35
```

---

## 🚀 Install — 3 steps

### 1️⃣ Install **bun**

```bash
curl -fsSL https://bun.sh/install | bash
```

> **Windows PowerShell**
> ```powershell
> irm https://bun.sh/install.ps1 | iex
> ```

Restart your shell so PATH is refreshed.

### 2️⃣ Install **claude-hud** plugin (inside Claude Code)

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud@claude-hud
/claude-hud:setup
```

### 3️⃣ Install **this customization**

```bash
curl -fsSL https://raw.githubusercontent.com/JungmoKoo/claude-full-statusline/main/install.sh | bash
```

> **Windows PowerShell**
> ```powershell
> iwr https://raw.githubusercontent.com/JungmoKoo/claude-full-statusline/main/install.sh -OutFile "$env:TEMP\install.sh"
> & "$env:ProgramFiles\Git\bin\bash.exe" "$env:TEMP\install.sh"
> ```

**✅ Restart Claude Code.** Your `~/.claude/settings.json` is auto-backed up to `settings.json.bak.<epoch>`.

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
