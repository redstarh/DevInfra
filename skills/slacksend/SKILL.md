---
description: "Send text messages or files to Slack channels via ~/bin/slacksend. Use when user asks to send to Slack, share via Slack, post to a channel, upload a file to Slack, or notify via Slack. Default channel: clawair. Other channels: stockagent_ops, stockagent_bot."
---

# slacksend

Slack 채널에 텍스트/파일을 전송하는 skill. `~/bin/slacksend` (CLI) 래퍼야.

## When to invoke

다음 사용자 요청에 자동 매칭:
- "Slack으로 보내줘", "슬랙에 전송", "슬랙으로 알려줘"
- "clawair 채널에 보내", "stockagent_ops에 알림"
- "이 파일 슬랙에 올려줘", "보고서 Slack 공유"
- "결과를 slack으로 받아볼래"

명시적 invoke: `/slacksend`

## Channels

| Channel | Purpose |
|---------|---------|
| **`clawair`** (default) | 사용자 일상 알림 / 보고 (default) |
| `stockagent_ops` | StockAgent / NeoSA 운영 알림 (장애, kill_switch, 거래) |
| `stockagent_bot` | agent_bot 전용 |

## Usage

### 1. 텍스트 메시지
```bash
~/bin/slacksend -c <channel> "메시지 내용"
```

### 2. 파일 전송 (HTML, MD, JSON, image, etc)
```bash
~/bin/slacksend -c <channel> -f <file_path>
```

### 3. 파이프 입력
```bash
echo "텍스트" | ~/bin/slacksend -c <channel>
cat report.md | ~/bin/slacksend -c <channel>
```

### 4. 메시지 + 파일 동시
```bash
~/bin/slacksend -c <channel> -f <file_path> "파일에 대한 설명"
```

## Decision flow

사용자 요청 분석 시:

1. **채널 추정**:
   - 명시 (예: "stockagent_ops에") → 그대로 사용
   - 미명시 → `clawair` (default)
   - 운영/장애/거래 키워드 → `stockagent_ops` 추천

2. **콘텐츠 형식 추정**:
   - 사용자가 만든 파일 (HTML/MD/JSON) → `-f <file>` 사용
   - 짧은 텍스트 (1~5줄) → 따옴표로 직접 전달
   - 긴 텍스트 + 포맷 유지 → 파일로 저장 후 `-f`
   - 명령 결과 → 파이프

3. **확인 필요 케이스**:
   - 채널이 모호하고 운영 채널 후보일 때 → 사용자 confirm
   - 파일 크기 > 10MB → 사용자 confirm
   - 민감 정보 (키, 시크릿, 자본 정보) 의심 → 사용자 confirm

## Examples

### Ex 1. 보고서 HTML 전송
```
사용자: "이거 슬랙에 보내줘"
→ ~/bin/slacksend -c clawair -f /tmp/report.html
```

### Ex 2. 운영 알림
```
사용자: "kill_switch 발동했다고 ops 채널에 알려줘"
→ ~/bin/slacksend -c stockagent_ops "🔴 kill_switch B1 발동: ..."
```

### Ex 3. 명령 결과 전송
```
사용자: "neosa_status 결과 슬랙에"
→ ./tools/neosa_status.sh | ~/bin/slacksend -c clawair
```

## Output convention

전송 성공 시: `ok: file 'X' sent to #channel` 또는 `ok: text sent to #channel`
실패 시: stderr에 에러. 사용자에게 보고 + 재시도 옵션 제시.

## Constraints

- **민감 정보 자동 redact 없음**: 사용자가 sensitive 데이터 전송 요청 시 confirm 1회 강제
- **rate limit**: Slack API 한도 (1초당 1건 권장). 다량 전송 시 사이 sleep 권고
- **파일 크기**: Slack 무료 plan 1GB workspace 한도 인지
- **HTML preview**: Slack은 HTML 직접 렌더링 안 함 (파일 첨부로만 표시). 풍부한 시각화 필요 시 PDF/이미지 변환 검토

## Bot info

- Bot: `clawairbot` (SKFamily workspace)
- 정의: `~/.claude/CLAUDE.md` (Personal Rules 섹션 참조)

## Related

- 알림 채널 설정 변경은 `/update-config` (settings.json·hook) 참조
- 사용자 운영: NeoSA `paper_trader/alerter.py`가 동일 Slack webhook 별도 사용 (운영 자동 알림)
