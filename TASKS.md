# 작업 원장 — 태스크 원장 도구 (Backlog.md) · 리포 호스팅

> **범위**: 여러 프로젝트에 걸친 개발 인프라. 어느 개별 프로젝트에도 속하지 않는다 —
> 프로젝트별 원장(`OhMyEnglish/TASKS.md` 등)과 별개이고 서로의 상태를 참조하지 않는다.
> **이 파일이 이 작업 상태의 정본이다.**
>
> 조사: `docs/research/2026-08-30-wiki-task-tooling.html`
> 결정: `docs/design/2026-08-30-wiki-task-tooling-decision.md` — **§후속을 반드시 먼저 읽을 것**
> Gitea 브리핑: `docs/design/2026-08-30-gitea-briefing.html` — **폐기된 안. 이력으로만 보관**

_최초 작성 2026-08-30 · 최종 개정 2026-08-30 (Gitea 폐기 → Backlog.md 채택)_

---

## 확정된 결정

| # | 결정 | 결과 |
|---|---|---|
| A | `~/AgentDev`(stock-agent) | 통합하지 않고 그대로 둔다. Synology NAS remote 유지 |
| B | 리포 호스팅 정본 | **GitHub.** 자체 forge를 세우지 않는다 |
| C | git이 아닌 프로젝트 | 편입 완료 — `En-Coach`·`WSEAgent`·`DevInfra` |
| D | 공통 문서의 집 | `~/MyProject/DevInfra` 신설 (이 리포). `Research`는 흡수 후 폐기 |
| **E** | **Gitea 도입** | **폐기.** GitHub과 기능 중복이고, 문서화된 고통(Actions 2,000분)을 해결하지 않는다 |
| **F** | **태스크 원장 도구** | **`Backlog.md` 채택.** 층 ②만 대체하고 handoff(층 ①)·영구 지식(층 ③)은 그대로 |
| **G** | 도입 범위 | **`OhMyEnglish` 한 곳 시범** 후 확대 판단 |
| **H** | MCP 연동 | **켠다** — `backlog mcp start`, 프로젝트 스코프 |

---

## Task

상태: `대기` / `진행` / `완료` / `차단` / `폐기`. **완료 전환은 증거 열의 명령을 직접 돌려 출력을 확인한 뒤에만 한다.**

### 완료

| # | Task | 완료 증거 |
|--:|---|---|
| 0 | `DevInfra` 신설 + `Research` 내용 이관 | 파일 4개 이관 확인 |
| 1 | `En-Coach/.gitignore` 보강 | `check-ignore -v`: `.env`→`:2` · `.venv/pyvenv.cfg`→`:5` |
| 2 | `git init` 3개 + 최초 커밋 | `DevInfra 507f948`(6파일) · `En-Coach 7b9516d`(45파일) · `WSEAgent 1b429ed`(28파일) · **금지패턴 0건** |
| 3 | `OhMyEnglish`에서 문서 2건 `git rm` | `9165f06` · 이관 전 `diff -q` 동일성 확인 |
| 4 | `brew install backlog-md` | `backlog 1.50.1` (`/opt/homebrew/bin/backlog`) |
| 5 | `OhMyEnglish`에 `backlog init` + MCP 등록 + 상태 매핑 | 덮어쓴 파일 0 · **자동 커밋 없음**(HEAD `9165f06` 불변) · `.mcp.json` 생성 · `statuses`에 `Awaiting Decision` 추가 |
| 6 | 핵심 조작 검증 (상태·AC·의존성·브랜치 스캔) | `-s` · `--check-ac 1`→`- [x] #1` · `--dep`→`dependencies: - TASK-1` · `board`가 `"Indexing 2 other local branches"` |

### 남은 것

| # | Task | 상태 | 소유자 | 증거 기준 |
|--:|---|---|---|---|
| 7 | `.mcp.json` MCP 서버 **승인** | 대기 | **`OhMyEnglish` 세션** | `claude mcp list`에서 `backlog` = Connected |
| 8 | `TASKS.md` 마이그레이션 — 태스크 55행 → `backlog/tasks/`, 비태스크 37행 → `docs/` | **차단** | 캡틴 + `OhMyEnglish` 세션 | 아래 차단 사유 2건 해소 후 |
| 9 | `session-handover.md` §4 지표 #2를 줄 번호 → **태스크 ID**로 개정 | 대기 | 캡틴 | 개정 커밋 |
| 10 | GitHub 비공개 리포 생성 + 5개 push (`OhMyEnglish`·`cursor-todo-app`·`En-Coach`·`WSEAgent`·`DevInfra`) | 대기 | 캡틴 승인 후 | 리포별 `git push --all` 출력 |
| 11 | `remoteOperations: true` 복원 | 대기 | — | Task 10 이후. `backlog task list`에 경고 없음 |
| 12 | 시범 평가 → 확대 여부 결정 | 대기 | 캡틴 | 층 ①과의 이중 기입 발생 여부 실측 |
| 13 | (선택) 셀프호스티드 러너로 Actions 2,000분 문제 해결 | 대기 | 캡틴 | 이 원장 범위 밖일 수 있음 — SoP는 `~/AgentDev/docs/ops/` |

### 폐기 — Gitea 관련 (재개하지 않는다)

`brew install gitea` · `app.ini` 작성 · 기동·유휴 메모리 실측 · admin/org 생성 · 리포 5개 편입 ·
`gitea dump` 백업 리허설 · pull mirror — **전부 폐기.** 사유는 결정 E, 근거는 결정 문서 §후속.
재개 조건은 §후속의 "재검토 트리거"에만 있다.

---

## Task 8 차단 사유 — 2건

1. **`OhMyEnglish` 세션이 `TASKS.md`를 실시간으로 편집 중이다.** 관측: 315줄(이전 308줄), 소스 5개 modified.
   그 세션이 유휴일 때 하거나 그 세션에 넘긴다.
2. **분류 승인이 필요하다.** 표 92행 중 **약 40%(37행)가 태스크가 아니다** —
   `B`(캡틴 결정 12행) · `F`(전역 규약 판정 근거 11행) · `H`(구성 완료 기록 6행) · 관련 문서 지도(8행).
   일괄 변환하면 **결정 기록이 태스크로 변질된다.** 이 37행의 목적지(층 ③ 어디로)를 먼저 정해야 한다.

## 미결 · 리스크

- **Backlog.md는 handoff를 써주지 않는다.** 층 ①은 그대로 사람이 쓴다. 도구가 층 ②를 맡으면서
  **두 곳에 같은 상태를 적는 일이 생기는지**가 시범의 핵심 관찰 대상이다(Task 12).
- **`--ac`는 쉼표로 분리되지 않는다.** `--ac "a" --ac "b"`로 반복해야 한다. 실측으로 확인한 함정.
- **`statuses`는 CLI로 못 바꾼다** — `backlog/config.yml` 직접 편집. 다른 프로젝트로 확대할 때 반복된다.
- **`~/MyProject/Research`가 빈 채로 남아 있다.** 이 세션의 작업 디렉터리라서 지우지 않았다. 세션 종료 후 `rmdir`.
- **`redstarh/WSEAgent`가 GitHub에 이미 있고 비어 있다.** Task 10에서 새로 만들지 말고 그 리포에 push한다.
- **`ai-driven-development` remote가 404다.** Task 10에서 정리 대상.
- `OhMyEnglish`의 `backlog/`·`.mcp.json`은 아직 untracked다. 그 세션이 커밋 시점을 정한다.

## 결정 기록 (뒤집힌 것 포함)

| 날짜 | 결정 | 상태 |
|---|---|---|
| 2026-08-30 | 위키 도구를 세우지 않고 리포의 `docs/**.md` 렌더링으로 대체 | 유효 (GitHub이 렌더링) |
| 2026-08-30 | 태스크 상태의 정본은 **리포 안 평문 md** | 유효 — 형태만 `TASKS.md` → `backlog/tasks/*.md` |
| 2026-08-30 | ~~Backlog.md는 인계 규약(`TASKS.md:줄번호`) 때문에 보류~~ → **채택.** 줄 번호가 지킬 제약이 아니라 고칠 대상이었다 — 태스크 ID는 밀리지 않는다 | 뒤집힘 |
| 2026-08-30 | ~~Gitea 하나를 도입한다 (165MB)~~ → **폐기.** GitHub과 중복이고 Actions 분 문제를 해결하지 않는다 | 뒤집힘 |
| 2026-08-30 | ~~"Gitea Wiki로 리포 `docs/`를 위키 정본 삼기"를 확인할 가치가 있다~~ → **기각** (`models/repo/wiki.go:74`, `gitea#23640` open) | 뒤집힘 |
| 2026-08-30 | ~~공통 문서를 `OhMyEnglish/docs/`에 둔다~~ → `DevInfra` 신설로 이관 (`9165f06`) | 뒤집힘 |
| 2026-08-30 | 용도를 단일 프로젝트에서 다중 프로젝트 공통으로 확장 | 유효 |
