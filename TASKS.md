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
| 8 | `TASKS.md` 마이그레이션 — 태스크 55행 → `backlog/tasks/`, 비태스크 37행 → 각 목적지 | **위임** | **`OhMyEnglish` 세션** | 작업 지시서(`af16aef`)의 완료 판정 6개. 완료 시 그 세션이 이 행을 갱신한다 |
| 8-1 | 비태스크 분류 확정 (캡틴 승인) | 완료 | — | 4묶음 목적지 확정 — 아래 §Task 8 분류 |
| 8-2 | `F`절(11행) 중 살릴 2건을 `~/.claude`로 이관 | 완료 | — | `code-development-principles.md` 꼬리에 "다시 삭제 후보로 올리지 말 것"으로 기록 |
| 9 | `session-handover.md` §4 지표 #2를 줄 번호 → **태스크 ID**로 개정 | 대기 | 캡틴 | 개정 커밋 |
| 10 | GitHub **공개** 리포 push — 4/5 완료 | 진행 | — | 아래 "Task 10 결과" 참조. `OhMyEnglish`만 남음 |
| 10-1 | **`OhMyEnglish` push 전 비밀값 처리** | **차단** | 캡틴 | 비밀번호 무효화(회전) 또는 비공개 push 결정 — 아래 차단 사유 |
| 11 | `remoteOperations: true` 복원 (`OhMyEnglish`) | 대기 | — | Task 10-1 이후. `backlog task list`에 경고 없음 |
| 12 | 시범 평가 → 확대 여부 결정 | 대기 | 캡틴 | 층 ①과의 이중 기입 발생 여부 실측 |
| 13 | (선택) 셀프호스티드 러너로 Actions 2,000분 문제 해결 | 대기 | 캡틴 | 이 원장 범위 밖일 수 있음 — SoP는 `~/AgentDev/docs/ops/` |

### 폐기 — Gitea 관련 (재개하지 않는다)

`brew install gitea` · `app.ini` 작성 · 기동·유휴 메모리 실측 · admin/org 생성 · 리포 5개 편입 ·
`gitea dump` 백업 리허설 · pull mirror — **전부 폐기.** 사유는 결정 E, 근거는 결정 문서 §후속.
재개 조건은 §후속의 "재검토 트리거"에만 있다.

---

## Task 10 결과 — 4개 공개 push 완료 (2026-08-30)

캡틴 결정: **공개로 해도 된다**(나중에 필요하면 변경) · **`ai-driven-development`는 push하지 않는다**.

push 전 5개 리포 전수 비밀값 스캔을 돌렸고, **깨끗한 4개만** 올렸다.

| 리포 | GitHub | 파일 | 검증 |
|---|---|---|---|
| `WSEAgent` | `redstarh/WSEAgent` (기존 빈 리포에 push) | 28 | 비밀값 후보 0건 |
| `cursor-todo-app` | `redstarh/cursor-todo-app` (신규) | 17 | 비밀값 후보 0건 |
| `En-Coach` | `redstarh/En-Coach` (신규) | 57경로 | **GitHub 트리에 금지패턴 0건** (`.venv`·`__pycache__`·`.env` 미포함 확인) |
| `DevInfra` | `redstarh/DevInfra` (신규) | 6 | 조사용 테스트 비밀값 3종 미유입 확인 (전부 `<생성>` 플레이스홀더) |

전부 `private=false` · `main` 추적 · 로컬과 동기. `ai-driven-development`는 캡틴 지시로 제외(remote 404 정리도 불필요).

### 오탐이었던 것 (재검사 낭비 방지)

- `En-Coach/docs/operations/deployment.md` — `<password>`·`<long-random-secret>`·`<provider-key>` 전부 **플레이스홀더**
- `OhMyEnglish/docs/ops/iam-setup-nova-sigv4.md` — `AKIA...`·`...`로 **생략 표기**, 실제 AWS 자격증명 아님
- `OhMyEnglish/app/frontend/package-lock.json`의 고엔트로피 문자열 — npm `integrity` **sha512 해시**
- 각 `config.py` — 환경변수를 읽고 기본값이 빈 문자열

## Task 10-1 차단 사유 — `OhMyEnglish`에 실제 비밀값이 이력에 있다

**`docs/ops/shared-database-naming-rules.md`에 Postgres 역할 `en_coach`의 평문 비밀번호가 있다.**
커밋 `7a5bfce`("docs: 전달 문서에 접속 비밀번호 포함")로 들어왔고 **현재 트리와 이력 양쪽에 존재**한다.
`git log -S`로 확인한 결과 이 값이 등장한 커밋은 `7a5bfce` 하나이고, 다른 4개 리포에는 없다.

문서 자신이 *"로컬 dev 전용이다. 이 문서가 git에 있으므로 원격·공유 환경에는 이 값을 쓰지 않는다"*라고 적어 두었다 —
**그 전제는 리포가 비공개일 때만 성립한다.** 공개로 올리면 동작하는 자격증명을 게시하는 것이 되고,
**파일을 지워도 커밋 `7a5bfce`는 남는다.** 공개 push 이후에는 GitHub이 캐시·인덱싱하므로 사후 제거로는 되돌릴 수 없다.

선택지 (캡틴 결정):

| 안 | 내용 | 비용 |
|---|---|---|
| **회전 후 공개** | 비밀번호를 새로 발급해 유출된 값을 무효화한 뒤 공개 push. 문서가 절차를 이미 담고 있다 — `podman exec -i ohmy-pg psql -U ohmy -d ohmyenglish -c "alter role en_coach password '<새값>'"` + 양쪽 `.env` 갱신 | 실행 중인 로컬 DB와 `OhMyEnglish`·`En-Coach` 양쪽 `.env`를 건드린다 → **그 세션 소관** |
| **이 하나만 비공개** | `OhMyEnglish`만 `--private`로 push. 나머지 4개는 이미 공개 | 이력 정리 불필요, 즉시 가능 |
| **이력 재작성 후 공개** | `git filter-repo`로 `7a5bfce`에서 값 제거 | **그 세션이 실시간 작업 중이라 매우 파괴적** — 권하지 않는다 |

## Task 8 분류 — 확정 (2026-08-30 캡틴 승인)

`OhMyEnglish/TASKS.md` 315줄 · 표 92행. 차단 사유 2건은 모두 해소됐다 —
분류는 캡틴이 확정했고, **실행은 `OhMyEnglish` 세션에 넘겼다**(그 세션이 `TASKS.md`를 실시간 편집 중이라
외부 세션이 손대면 충돌한다). 작업 지시서: `OhMyEnglish/docs/design/2026-08-30-tasks-md-migration-spec.md` (`af16aef`).

| 갈래 | 섹션 | 행 | 목적지 | 판정 이유 |
|---|---|--:|---|---|
| **태스크** | `A` `G` `E` `C` `D` | 55 | `backlog/tasks/*.md` | 끝낼 주체와 시점이 있다 |
| 비태스크 ① | `B. 캡틴 결정` | 12 | `docs/design/2026-08-30-captain-decisions-phase1.md` (신설) | `B-1`~`B-10` 전부 `종결`. 결정+근거이므로 요약 금지 — 근거가 잘리면 다시 뒤집힌다 |
| 비태스크 ② | `F. 전역 규약 정리` | 11 | **이 리포에서 삭제** | 범위가 `~/.claude/**`로 애초에 이 리포 것이 아니다. 실측표(5행)는 `~/.claude` git 이력이 이미 갖고 있어 버린다. 살릴 2건은 **Task 8-2로 이관 완료** |
| 비태스크 ③ | `H. DB 공유` | 6 | `docs/ops/shared-database-guide.md`로 축약 | 철회안은 그 가이드 §4-alt에 이미 보존됨(중복). 살릴 것은 `H-3` 실측값 한 줄 |
| 비태스크 ④ | `관련 문서 지도` | 8 | 리포 루트 `README.md` | 순수 인덱스. "무엇이 남았나 → 이 파일" 행은 `backlog board`로 고친다 |

**판별 기준**: "이것을 누가 언제 끝내는가?"에 답이 없으면 태스크가 아니다.

주의 2건을 지시서에 실었다: **`B-5`~`B-8`이 `G-4`~`G-7`을 가리키므로** 결정 문서에서 **새 태스크 ID로 재링크**해야
한다(줄 번호 금지). 그리고 **`H-2`가 가리키는 파일이 비밀번호 유출 지점**이라 Task 10-1과 같은 건이다.

## 미결 · 리스크

- **Backlog.md는 handoff를 써주지 않는다.** 층 ①은 그대로 사람이 쓴다. 도구가 층 ②를 맡으면서
  **두 곳에 같은 상태를 적는 일이 생기는지**가 시범의 핵심 관찰 대상이다(Task 12).
- **`--ac`는 쉼표로 분리되지 않는다.** `--ac "a" --ac "b"`로 반복해야 한다. 실측으로 확인한 함정.
- **`statuses`는 CLI로 못 바꾼다** — `backlog/config.yml` 직접 편집. 다른 프로젝트로 확대할 때 반복된다.
- **`~/MyProject/Research`가 빈 채로 남아 있다.** 이 세션의 작업 디렉터리라서 지우지 않았다. 세션 종료 후 `rmdir`.
- ~~`redstarh/WSEAgent`가 비어 있다~~ → **해소.** 그 리포에 push 완료 (새로 만들지 않았다).
- ~~`ai-driven-development` remote가 404다~~ → **범위 밖.** 캡틴 지시로 push하지 않는다.
- **비밀값 스캔을 편입 절차에 고정한다.** 이번에 `OhMyEnglish` 1건을 잡았다. 공개 push는 되돌릴 수 없으므로
  새 리포를 올릴 때마다 ① 추적 파일 패턴 스캔 ② `git log -S`로 이력 확인 ③ push 후 GitHub 트리 재검사를 반복한다.
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
