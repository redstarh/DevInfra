---
description: "Run an external, read-only audit of a project's Backlog.md ledger from a separate session — catches instructions the work session acknowledged but never executed. Use when the user asks for a task-manager watchdog, an outside check on work progress, an audit session, or a kanban/audit panel showing whether backlog work is actually advancing. Also use when a work session has repeatedly promised something and not delivered."
---

# external-audit

작업 세션이 **자기 원장을 보고 다음 행동을 고르지 않는** 고장을 밖에서 잡는다. 원장을 읽고,
어긋남을 계산해, 두 표면(메시지 · 패널)에 남긴다. **원장·코드·문서에 쓰지 않는다.**

## 왜 세션 안의 체크리스트로는 안 되나

실측된 고장은 이렇다 — 원장이 정확했고 태스크도 등록돼 있었는데 작업 세션이 캡틴 지시를
**두 번 물어 두 번 다 답만 하고 만들지 않았다.** 원인은 정보 부재가 아니라 **원장을 참조하지
않은 것**이다. 그래서 같은 세션 안의 체크리스트는 원리적으로 못 막는다 — 볼 의지가 없는 것이
고장이니 체크리스트를 하나 더 얹어도 같이 무시된다. **감사자는 별도 세션이어야 한다.**

부수 효과가 본질이다: 감사자는 작업 세션의 의지에 걸리지 않으므로, 작업 세션이 판정을
뒤집어야 할 때 그 근거를 외부에서 공급한다(실측: 1회차에 종결된 태스크 하나가 되돌아갔다).

## 원칙 3개

1. **외부**: 별도 세션. subagent로 만들지 않는다 — 같은 컨텍스트면 같은 눈이다.
2. **읽기 전용**: 발견은 보고하고 고치지 않는다. 원장은 잠금 없는 평문 md이고 `auto_commit: false`라
   git도 중재하지 않는다 — 작업 세션과 동시에 쓰면 한쪽이 조용히 사라진다.
3. **생존 신호**: 감사자가 죽어 조용한 것과 어긋남이 없어 조용한 것은 밖에서 같아 보인다.
   매 주기 흔적을 남겨 그 둘을 구별한다. **거르면 감사 전체가 무의미해진다.**

## 감사 4항목 — 매 주기 전부

| # | 무엇 | 판정 |
|---|---|---|
| **A** | 지시 라벨(`caps-req` 등)이 붙었는데 완료가 아닌 태스크 | 개수 + ID. `priority: high`는 따로 |
| **B** | **선행이 다 풀렸는데 자신은 미착수** | ⚠️ 가장 중요. 실제 누락이 이 형태로 났다 |
| **B'** | 선행 미충족인데 **진행 중** | 순서 역전 |
| **C** | 가장 최근 완료 1건의 **주장 대 증거** | 파일이면 존재+줄 수, DB면 조회(읽기만), 판정이면 근거 문서, 에이전트면 그 산출물 |
| **D** | 방식이 지시된 것을 산출물로 대체했는지 | *"X를 활용해서 해라"*면 **X를 만들어 쓴 것까지가 이행**. 결과만 있으면 미이행 |

A·B·B'는 `scripts/audit_panel.py`가 계산한다. **C·D는 사람 판단이라 매 주기 직접 한다.**

**상태만 읽고 "정상"이라 보고하지 않는다** — 상태는 주장이고 증거가 아니다. 완료로 올린 판정이
한 시간 안에 리뷰에서 뒤집힌 사례가 실재한다.

## 보고 — 두 표면

**① 작업 세션에 메시지.** `ListAgents`로 대상을 찾고 `SendMessage`로 보낸다.
tmux `send-keys`를 쓰지 않는다 — 긴 한 줄은 첫 Enter가 삼켜진다(실측).
15줄 이내. **어긋남을 첫 줄에.** 0건이면 0건이라 적는다 — 없는 것을 만들지 않는다.

**② 패널 + 생존 신호.** 둘 다 `.harness/`에 쓴다. 추적 밖 경로여야 한다:

```bash
git check-ignore -v .harness/            # 비면 먼저 .git/info/exclude 에 넣게 사용자에게 알린다
python3 ~/.claude/skills/external-audit/scripts/audit_panel.py <repo> --round <N>
date '+%Y-%m-%d %H:%M:%S' > <repo>/.harness/audit-heartbeat.txt          # 최신 상태(덮어쓴다)
echo "회차=<N> 미이행=<M> 어긋남=<K>" >> <repo>/.harness/audit-heartbeat.txt
# 발동 이력은 **별도 append-only 로그**에 남긴다 — heartbeat 는 덮어쓰므로 이력이 안 남는다
echo "$(date '+%F %T') 회차=<N> 발동=<자동|수동> 어긋남=<K>" >> <repo>/.harness/audit-fire-log.txt
```

패널을 브라우저로 보려면 `.harness/`를 정적 서빙한다(칸반과 다른 포트):
`python3 -m http.server 6421 --bind 127.0.0.1` → `http://127.0.0.1:6421/audit-board.html`

**감사 결과를 원장에 넣지 않는다.** "어긋남 3건"은 끝낼 사람이 없는 관측값이라 태스크가 아니다
(`~/.claude/rules/task-management.md` §4의 판별 질문). 원장에 넣으면 결정 기록이 태스크로
변질된다. 그래서 칸반 **안**이 아니라 **옆**에 놓는다.

## 절대 금지

원장 쓰기(`task edit`·`create`·`delete`) · 코드·문서·설정 수정 · 커밋 · 테스트 스위트 실행
(공유 테스트 DB가 실행마다 DROP/CREATE되는 프로젝트가 있다) · 실행 중인 앱 프로세스 종료·재기동 ·
개발 DB 쓰기. **`idle`을 "완료"로 읽지 않는다** — 완료는 산출물의 존재로만 판정한다.

## 도입

```bash
# 1) 감사자용 새 세션을 띄운다 (절차: ~/.claude/rules/session-handover.md §3)
# 2) 그 세션에서:
/loop 1h 너는 외부 감사 세션이다. <repo>/docs/ops/audit-session-brief.md 를 읽고
         external-audit skill 의 4항목을 수행해라. 보고는 두 표면 모두에.
```

주기는 **1시간**을 기본으로 한다 — 작업 세션이 태스크 하나를 닫는 데 그보다 오래 걸리므로
더 자주 돌면 같은 값을 다시 읽는다. `CronCreate`는 `durable: true`로 건다(세션이 죽어도 살아남게).
**7일 자동 만료는 durable로도 없어지지 않는다** — 만료일을 사용자에게 알린다.

프로젝트별로 다른 것(리포 경로 · 지시 라벨 이름 · 보존 대상 데이터 · 죽이면 안 되는 포트)만
`<repo>/docs/ops/audit-session-brief.md`에 둔다. **이 파일의 내용을 그 브리프에 복사하지 않는다.**

## 실측 함정

- **라벨은 `labels:` 필드에서만 센다.** 파일 전체에서 문자열을 찾으면 본문 언급까지 잡혀 부풀려진다.
- **원장의 `created_date`·`updated_date`는 UTC로 적힌다.** 현지 시각과 어긋나므로(KST면 9시간)
  "선행이 풀린 지 N분 만에" 같은 시각차 판정에 반드시 보정한다. 파일 mtime·커밋 시각으로 교차 확인한다.
- **`backlog board export`에 절대경로를 줘도 리포 안에 떨어진다.** `/tmp/x.md`가 `<repo>/tmp/x.md`가 된다.
- **보드는 다른 브랜치 상태까지 병합해 보여준다.** 보드와 내가 읽은 파일이 다르면 **내 스냅샷이
  낡은 것을 먼저 의심한다** — 작업 세션이 그 사이에 커밋했을 수 있다.
- **명령이 오류로 끝났는데 출력이 비어 "없음"으로 읽히는 것**을 경계한다. 출력이 비면 exit code를 먼저 본다.
- **어긋남이 의존 그래프 수정으로 사라질 수 있다.** 선행을 미완료 태스크로 교체하면 B가 조용히
  0이 된다. 일을 해서 닫힌 것과 그래프를 바꿔 닫힌 것을 구별해 기록한다(실측 1건).
- **`SendMessage`의 `success: true`는 "접수"이고 "도달"이 아니다.** 수신 측 사용자 승인 게이트에
  걸리면 상대 Claude는 아직 못 본다 — 실측: 2주기 연속 걸렸고, 두 번째는 성공 응답만 보고
  "바로 도달"이라 적었다가 정정해야 했다. **도달은 별도로 오는 승인·해제 통지로만 판정한다.**
  생존 신호에는 접수 시각과 도달 시각을 **따로** 적는다.

## 관련

`~/.claude/rules/task-management.md`(원장 조작·상태 정의) · `session-handover.md`(새 세션 생성) ·
`self-verification-gate.md`(증거는 내가 직접, 판정은 위임). 색·레이아웃은 `dataviz` skill의
검증된 값을 쓴다 — `scripts/audit_panel.py`에 박혀 있고 라이트·다크 전 항목 PASS다.
