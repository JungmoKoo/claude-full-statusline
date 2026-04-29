# claude-hud-share

Claude HUD 표시 옵션 + statusline 끝에 8자리 SessionID를 회색으로 붙이는 커스텀 설정.

## 사전 조건

- Claude Code 안에서 `/claude-hud:setup`을 한 번 실행해 둔 상태
- `jq`, `bun`이 설치되어 있을 것
  - 확인: `command -v jq && command -v bun`

## 설치

```bash
git clone <repo-url> claude-hud-share
cd claude-hud-share
./install.sh
```

설치가 끝나면 Claude Code를 재시작하세요. statusline 첫 줄 끝에 ` | SessionID: xxxxxxxx`(회색)이 보이면 성공.

## 무엇을 바꾸는가

- `config.json` → `~/.claude/plugins/claude-hud/config.json`로 복사 (HUD 표시 옵션)
- `~/.claude/settings.json`의 `statusLine.command`를 SessionID 후처리가 들어간 버전으로 교체

기존 `settings.json`은 자동으로 `settings.json.bak.<epoch>`로 백업됩니다.

## 원복

```bash
ls -t ~/.claude/settings.json.bak.* | head -1 | xargs -I{} cp {} ~/.claude/settings.json
```

## 커스터마이즈

표시 옵션을 바꾸고 싶다면 `config.json`만 수정하고 `./install.sh`를 다시 돌리면 됩니다.
