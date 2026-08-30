# 결정 — 위키 · Task/PR 도구 (2026-08-30)

> ## ⚠️ 먼저 읽을 것 — 결정 1번은 같은 날 폐기됐다
>
> **`Gitea`를 도입하지 않는다.** 아래 "결정 3건"의 1번은 **2026-08-30 최종 검토에서 폐기**됐고,
> 대신 **`Backlog.md`**를 채택했다. 전환 근거와 검증은 이 문서 맨 아래 **"§후속 — Gitea 폐기와 Backlog.md 채택"**에 있다.
> 아래 본문은 *"어느 self-hosted forge냐"*를 비교한 기록으로서 유효하다 — 그 질문의 전제가 틀렸다는 것이 후속의 내용이다.
>
> **한 줄 요약**: GitHub이 이미 소스·문서·이슈·PR을 덮고 있어 forge는 중복이었다. 실제로 필요한 것은
> forge가 아니라 **세션 인계를 견디는 태스크 원장 도구**였고, 그건 이 문서가 "보류"로 처리한 `Backlog.md`다.
>
> **상태: 1번 폐기 · 2번 수정 · 3번 유효.** 근거 조사: `docs/research/2026-08-30-wiki-task-tooling.html`.
> 이 문서는 **결정과 근거**만 담는다. 후보별 판정·실측 수치는 보고서가 정본이다.
> 재논의 방지가 목적이다 — 아래 "기각한 대안"을 다시 검토하기 전에 "재검토 트리거"를 먼저 확인할 것.
>
> **적용 범위 (2026-08-30 확장)**: 처음엔 `OhMyEnglish` 하나를 대상으로 썼고, 같은 날 **여러 프로젝트 공통**으로
> 확장됐다. 세 결정은 그대로 유효하며 해석만 프로젝트별로 적용된다 — 특히 결정 2번의 "`TASKS.md`가 상태의 정본"은
> **각 프로젝트의 `TASKS.md`**를 뜻한다. forge 구축 작업 자체의 원장은 `TASKS.md`(이 리포 루트)다.
> 확장에 따라 이 문서는 `OhMyEnglish`에서 `DevInfra`로 이관됐다(`9165f06`).

---

## 결정 3건

| # | 결정 | 근거 (한 줄) |
|--:|---|---|
| 1 | **Gitea 하나를 도입한다** (네이티브, brew) | 이슈+PR 리뷰+칸반을 단일 프로세스로 덮는다. 유휴 **165MB 실측**. 지금 리포는 remote가 없어 PR 개념 자체가 없는데, 로컬 forge를 remote로 붙이면 한 번에 해결된다 |
| 2 | **`TASKS.md`를 상태의 정본으로 유지한다** | 세션 인계 지표가 `TASKS.md:<줄번호>`로 위치를 지목한다. 정본을 옮기면 그 참조 체계를 재설계해야 하고, 이것이 이 선택지들 중 되돌리기가 가장 비싸다. Gitea 이슈는 **버그/PR 트래킹에만** 쓴다 |
| 3 | **위키 도구를 세우지 않는다** | Gitea 리포 브라우저가 `docs/**.md`를 그대로 렌더링한다. 현재 필요한 것은 "읽기 전용 문서 뷰"이고 이것으로 충족된다. 추가 상주 0 |

**총비용: 상주 프로세스 1개 · 유휴 ~165MB · 외부 DB 0 · 컨테이너 0.**

## 왜 이 조합인가

되돌리기 어려운 변경을 **하나도 하지 않는** 조합이다. Gitea는 지우면 끝이고(리포는 원래 것이 정본), `TASKS.md`는 건드리지 않았고, 위키는 세우지 않았다. 반대로 정본 이동(2번)과 위키 도구 채택(3번)은 나중에도 얹을 수 있다.

판정을 지배한 축은 **"컨테이너냐 네이티브냐"**였다. 이 맥의 podman machine 게스트가 컨테이너 0개 상태에서 이미 ~450MB를 커밋한다(`free -m` 실측 454/3890MB) — 앱이 100MB든 상관없이 VM이 예산을 먼저 먹는다. Gitea는 공식 darwin-arm64 바이너리와 Homebrew 병이 있어 이 비용이 0이다.

## 기각한 대안 — 다시 꺼내기 전에 읽을 것

| 대안 | 기각 사유 | 근거 |
|---|---|---|
| **Gitea Wiki로 `docs/` 정본** | **구조적으로 불가능.** 위키는 별도 `<repo>.wiki` git 리포가 정본이고, 메인 리포 폴더를 위키 소스로 지정하는 설정이 없다 | `models/repo/wiki.go:74` (`repo.Name+".wiki"`) · `models/repo/repo.go:77` (`*.wiki` 예약) · `repo.go:654` (`IsWikiRepo`는 `.wiki` 접미사 판정) · 기능 요청 `go-gitea/gitea#23640 "Publish code as wiki"`가 2023-03-22 생성 후 **여전히 open** |
| **Otter Wiki 즉시 채택** | 기각이 아니라 **보류**. 위키 정본이 리포 `docs/`여야 한다면 +160MB(네이티브)는 협상 불가인 확정 비용이다 — 지금은 그 값을 낼 이유가 없다 | 보고서 A절 |
| **Backlog.md로 `TASKS.md` 이전** | 기각이 아니라 **보류**. 도구 자체는 제약을 만족함을 확인했다(아래) — 막는 것은 도구가 아니라 인계 규약이다 | 결정 2번 |
| **Forgejo** | darwin 릴리스 자산이 없다(리눅스 전용). brew 또는 podman VM ~450MB가 필요 | 보고서 B절 |
| **Wiki.js** | 공식 문서 축자: *"A Git repository must be dedicated to Wiki.js. It is not possible to use only a subfolder"* → 이 리포 `docs/` 지정이 공식 불가 | 보고서 A절 |
| **Outline** | 라이선스 본문이 스스로 *"is not an Open Source license"*(BSL 1.1) → 요건 탈락 | 보고서 A절 |
| **LeafWiki** | 외부에서 넣은 md에 `leafwiki_id` frontmatter를 **디스크에 되쓰기**하고 opt-out이 없다 → git diff 오염 | README 자기 인정 |
| **Plane / GitLab CE** | 리소스 과잉. Plane은 compose 서비스 13개 + SQLite 축소가 구조적 불가(`ArrayField`/`ArrayAgg`는 PostgreSQL 전용), GitLab은 공식 하한이 *"at least 8 GB of memory"* | 보고서 B절 |

### Backlog.md — 검증됐고 보류된 것 (2026-08-30 실측)

나중에 결정 2번을 뒤집을 때 재조사하지 않도록 확인 결과를 남긴다. 실제 리포의 태스크 파일(`backlog/tasks/back-200 - ....md`)을 직접 열어 확인했다.

- **정본**: `backlog/` 폴더 안 평문 md, 태스크 1개 = 파일 1개. 공식 문구 *"Local-first — no server, no account, no telemetry; tasks are plain files in your repo."*
- **상주 0 확인**: CLI 전용. 웹 UI는 `backlog browser`로 온디맨드, `127.0.0.1` 바인딩, 프로세스 종료 시 사라진다
- **설치**: `brew install backlog-md` (npm/bun/nix도 있음)
- **frontmatter를 도구가 쓴다** — `id`/`status`/`labels`/`dependencies`/`priority`/`updated_date`. LeafWiki 탈락 사유와는 성질이 다르다(**남이 쓴 md 오염이 아니라 도구가 만든 자기 포맷**). 단 `updated_date`가 변경마다 갱신되므로 **손댈 때마다 diff에 한 줄 노이즈**가 붙는다
- **`dependencies` 필드가 있다** → "착수 전 필수 조건" 추적에 그대로 맞는다
- **PR은 못 덮는다** — Plan/Task/Status만. 요구사항 B의 4개 중 3개다

## 확정된 첫 걸음

1. `brew install gitea` → SQLite로 기동 → `git remote add local <로컬 forge>` 후 push. 이슈·PR·칸반이 한 번에 생긴다.
2. 설치 위저드 없이 HTTP 200이 뜨는 **최소 `app.ini`** 구조는 실측으로 확인됐다. 키는 아래이고, **비밀값 3개는 반드시 새로 생성한다**(조사 때 쓴 값을 재사용하지 말 것 — `gitea generate secret SECRET_KEY` / `INTERNAL_TOKEN` / `JWT_SECRET`).

```ini
RUN_MODE = prod
WORK_PATH = <작업 경로>
[server]
HTTP_ADDR = 127.0.0.1        ; 외부 노출 금지
HTTP_PORT = <포트>
ROOT_URL = http://127.0.0.1:<포트>/
DISABLE_SSH = true
OFFLINE_MODE = true
LFS_START_SERVER = false
[database]
DB_TYPE = sqlite3            ; 외부 DB 0
PATH = <경로>/data/gitea.db
[repository]
ROOT = <경로>/data/repos
[security]
INSTALL_LOCK = true          ; 설치 위저드 건너뛰기
SECRET_KEY = <생성>
INTERNAL_TOKEN = <생성>
[service]
DISABLE_REGISTRATION = true
[log]
LEVEL = warn
[indexer]
ISSUE_INDEXER_TYPE = bleve   ; 이슈가 쌓이면 메모리가 165MB 위로 오른다
[oauth2]
JWT_SECRET = <생성>
```

3. `TASKS.md`는 **그대로 둔다.** 이슈로 이중 등록하지 않는다 — 결정 2번이 정본 이동을 보류했으므로 병행 운영도 하지 않는다.

## 재검토 트리거

이 결정을 다시 열 조건을 미리 못 박는다. 조건 없이 재논의하지 않는다.

| 결정 | 뒤집을 조건 |
|---|---|
| 3번 (위키 없음) | 위키링크·백링크·전문검색 기반 지식 그래프가 **실제 작업을 막을 때**. "있으면 좋겠다"는 트리거가 아니다 |
| 2번 (`TASKS.md` 정본) | 인계 지표를 줄 번호가 아닌 방식으로 재설계할 의사가 생겼을 때. 그때 Backlog.md는 위 검증 결과를 재사용한다 |
| 1번 (Gitea) | 유휴 메모리가 실사용에서 예산(≤512MB)을 위협할 때. bleve 이슈 인덱서가 주된 증가 요인이다 |

## 이 결정이 남긴 미확인 — 전부 조건부

| 미확인 | 언제 문제가 되나 |
|---|---|
| Otter Wiki가 백업 디렉터리(`docs/backup/**`)를 위키 노출에서 제외하는 공식 수단 | 결정 3번을 뒤집을 때만. 수단이 없으면 별도 clone이 필수가 되고 "리포 md가 제자리에서 정본"이라는 채택 이유가 약해진다 |
| SilverBullet 유휴 RSS · 대소문자 구분 없는 기본 APFS에서의 실제 실패 양상 | 결정 3번을 뒤집으면서 Otter Wiki를 **안** 고를 때만 |
| `TASKS.md` 308줄의 태스크 분해 규모 · 인계 규약 재작성 분량 | 결정 2번을 뒤집을 때만 |

**미검증 후보를 추가 조사하지 않기로 한 이유**: DokuWiki·Gollum·TiddlyWiki·Trilium·MkDocs·mdBook·Quartz·Obsidian·Logseq·Joplin·Vikunja·Kanboard·Wekan·Leantime·Taskwarrior·dstask·radicle·jj는 3표 검증에 오르지 못했으나, 1순위 후보가 제약(상주 최소·정본 평문 md·오픈소스)을 이미 전부 만족했다. 추가 조사의 기대값보다 결정을 미루는 비용이 크다고 판단했다.

## 시효

Gitea v1.27.3 · Otter Wiki v2.24.0 · SilverBullet push가 모두 2026-08-29, Forgejo v16.0.3이 2026-08-20 — 조사 시점 열흘 내다. **버전·메모리 수치는 수 주 안에 낡는다.** 결정의 구조(네이티브 우선·정본 유지)는 버전과 무관하지만, 165MB 같은 수치를 재인용할 때는 재측정할 것.

---

## §후속 — Gitea 폐기와 Backlog.md 채택 (2026-08-30 최종 검토)

캡틴 질의: *"현재 Gitea가 GitHub으로 이미 관리하고 있는데 필요한 것인가? 중복된 기능을 가져가는 것은 아닌지?"*
→ **중복이 맞다. Gitea를 폐기한다.**

### 폐기 근거 (직접 확인)

| # | 사실 | 확인 방법 |
|---|---|---|
| 1 | **이미 GitHub에 비공개 리포를 쓰고 있다** — `stock-agent` private=true, `ml_intern` private=true | `gh repo list` |
| 2 | **`redshoehat/WSEAgent`가 GitHub에 이미 있고 비어 있다** (size=0KB, `"This repository is empty"`, 2026-08-19) → 원래 의도가 GitHub이었다는 직접 증거 | `gh api repos/redstarh/WSEAgent` |
| 3 | **문서화된 고통은 이슈/PR이 아니라 Actions 분(分)이다** — `~/AgentDev/docs/ops/github-ci-cost-reduction-sop.md` 312줄, 사건 `2026-04-27~05-01 Free plan 2000분 한도 초과` | 파일 직접 확인 |
| 4 | **Gitea는 그 고통을 해결하지 않는다** — 브리핑에서 Actions를 끄기로 했다 | 이 리포 브리핑 |
| 5 | **그 고통은 GitHub에서 공짜로 해결된다** — *"GitHub Actions usage is free for self-hosted runners"* (셀프호스티드 러너 분은 2,000분 한도에 미포함) | GitHub 공식 과금 문서 |
| 6 | `ai-driven-development` remote는 깨져 있다 (404) | `gh api` |

브리핑에서 "켠다"고 한 6개(이슈·PR 리뷰·칸반·마크다운 렌더링·Org/Team·비공개 리포)가 **전부 GitHub Free에 있다.**
Gitea가 유일하게 더 주는 것은 오프라인 동작 · 코드가 기기를 안 떠남 · 벤더 비의존인데, **셋 다 이 환경의 실제 제약이 아니다**(사실 1번).
반대로 Gitea가 가져가는 것은 유휴 165MB + 상주 1개(영구), 그리고 **백업 책임** — 이슈·PR·리뷰 코멘트가 SQLite에만 있어
디스크 고장이 리뷰 이력을 지운다. GitHub은 오프사이트 이중화를 공짜로 준다.

### 조사가 이것을 놓친 이유 — 재발 방지용으로 남긴다

원 요청이 *"Opensource wiki 추천"* / *"Opensource 추천"*이었다. 조사는 **"어느 오픈소스냐"**를 정확히 답했지만
**"이미 GitHub이 덮고 있는데 self-hosted가 필요한가"**는 묻지 않았다 — GitHub은 오픈소스가 아니라 후보 집합에서
구조적으로 빠져 있었다. **제약 조건이 가장 좋은 답을 걸러냈다.** 에이전트 104개를 돌려도 전제를 의심하지 않으면
이런 종류는 잡히지 않는다. **다음 조사에서는 "이 요구를 이미 충족하는 기존 자산이 있는가"를 후보 열거보다 먼저 묻는다.**

### 실제 요구 — forge가 아니라 원장 계층

캡틴 재정의: *"GitHub이 문서 버전이나 소스를 관리하고 있으면 도입하지 말고, 개발 진행간 Task plan과 task를
다른 세션이 넘어가도 handoff를 만들면 task 실행상태로 관리하는 도구가 필요해. 간단하지만 일관성있게 로컬에서 쓸 수 있는 Tool."*

3층 규약(`CLAUDE.md <work_continuity>`)에 얹으면 필요한 자리는 **하나**다.

| 층 | 담당 | 이번 결정 |
|---|---|---|
| ① 연속성 (다음 한 걸음·착수 전 필수·실측값) | `handoff/HANDOFF-*.md` | **변경 없음** |
| ② 작업 원장 (전체 Task와 진행 상태) | `TASKS.md` 수기 | **`Backlog.md`로 대체** |
| ③ 영구 지식 (결정·함정) | `docs/design/`, `docs/ops/` | **변경 없음** |

### 결정 2번의 수정 — 그리고 내가 틀렸던 지점

원 결정 2번은 *"`TASKS.md`를 상태의 정본으로 유지"*였고, `Backlog.md`를 **"인계 규약(`TASKS.md:줄번호`) 때문에 보류"**로
처리했다. **그 판단이 틀렸다.** 줄 번호 참조를 *지켜야 할 제약*으로 취급했지만, 실은 그것이 **고쳐야 할 대상**이었다 —
줄 번호는 편집마다 밀려서 낡는다(`session-handover.md`가 `file:line` 인용을 매번 확인하라고 요구하는 이유가 그것이다).
**태스크 ID는 밀리지 않는다.** 즉 `Backlog.md`는 인계 지표를 깨지 않고 **더 안정적인 지시자로 바꾼다.**

수정된 결정 2번: **정본은 여전히 리포 안 평문 md다.** 형태만 단일 `TASKS.md`에서 `backlog/tasks/<id> - <title>.md`
(태스크 1개 = 파일 1개)로 바뀐다.

### Backlog.md — 채택 근거 (이 맥에서 직접 실행해 확인)

`brew install backlog-md` → `backlog 1.50.1`. ★6,570 · MIT · 52주 커밋 826 · v1.50.1(2026-08-10) · push 2026-08-29.

| 요구 | 검증한 명령 · 결과 |
|---|---|
| 상주 0 · 로컬 | CLI 전용, DB 0. 웹 UI는 `backlog browser` 온디맨드(`127.0.0.1:6420`) |
| 일관성 (스키마 강제) | `backlog task create` → frontmatter `id/status/assignee/labels/dependencies/ordinal` 자동 생성 |
| 상태 관리 | `backlog task edit TASK-1 -s "In Progress"` → `status: In Progress` 반영 확인 |
| 실행 상태 세분화 | `backlog task edit TASK-1 --check-ac 1` → `- [x] #1` 반영 확인 |
| 선행 조건 (⛔ 차단) | `backlog task create ... --dep TASK-1` → TASK-2에 `dependencies: - TASK-1` |
| **세션·브랜치 넘김** | `backlog board` 실행 시 `"Indexing 2 other local branches"` → `"Applying latest task states from branch scans"` — **다른 브랜치의 태스크 상태를 병합해 보여준다** |
| AI 세션 연동 | `backlog mcp start` (MCP 서버) — Claude Code가 태스크 상태를 직접 읽고 갱신 |
| 탈출 비용 | 태스크 파일을 `rm`으로 지워도 도구가 정상 동작. 정본이 평문 md라는 성질의 직접 확인 |

**함정 1건**: `--ac`는 **쉼표로 분리되지 않는다.** `--ac "a,b"`는 AC 1건이 되고, 2건을 원하면 `--ac "a" --ac "b"`로
반복해야 한다(실측). 첫 시도에서 이 실수를 했다.

### 시범 설정 — `OhMyEnglish` (실측)

`backlog init "OhMyEnglish" --defaults --integration-mode mcp --auto-open-browser false`

- 덮어쓴 것 **없음** — `CLAUDE.md`·`AGENTS.md`·`backlog/`가 모두 부재했음을 사전 확인
- **자동 커밋 없음** (`auto_commit: false`, HEAD `9165f06` 불변). 산출물은 untracked `backlog/`·`.mcp.json`
- MCP: `claude mcp add --scope project backlog -- backlog mcp start` → `.mcp.json` 생성, 상태 `Pending approval`
  (프로젝트 스코프라 그 리포에서 작업하는 세션이 승인해야 붙는다)
- `remoteOperations: false`로 내렸다 — remote가 없어 매 명령마다 경고가 났다. **GitHub remote를 붙이면 되돌린다**
- **상태 5개 → 4개 매핑**: `✅ 완료`→`Done` · `🔨 진행 중`→`In Progress` · `⏭ 대기`→`To Do` ·
  `⏸ 캡틴 결정 대기`→**`Awaiting Decision`**(신설) · `⛔ 차단`은 **상태가 아니라 `dependencies`로 표현**.
  `statuses`는 CLI로 못 바꾼다 — `backlog/config.yml`을 직접 편집해야 한다(실측)

### Backlog.md의 범위 밖 — 기대를 낮춰 둘 것

- **handoff를 써주지 않는다.** 다음 한 걸음 · 착수 전 필수 · 게이트 실측값은 층 ①이고 여전히 사람(에이전트)이 쓴다.
  도구는 *태스크 상태*를 일관되게 붙들고 *가리키는 방법*을 안정화한다.
- **마이그레이션은 기계적이지 않다.** `OhMyEnglish/TASKS.md` 315줄 · 표 92행을 분류해 보니
  **A(20행)·G(14행)·E(11행)·C(5행)·D(5행) = 55행만 태스크 성격**이고,
  **B(12행 캡틴 결정)·F(11행 전역 규약 판정 근거)·H(6행 구성 완료 기록)·관련 문서 지도(8행) = 37행(약 40%)은
  태스크가 아니다** — 층 ③으로 가야 한다. 일괄 변환하면 결정 기록이 태스크로 변질된다.

### 재검토 트리거

| 결정 | 뒤집을 조건 |
|---|---|
| Gitea 폐기 | 코드가 기기를 떠나면 안 되는 계약·고객 요구가 생길 때 · 오프라인 개발이 상시가 될 때 · "forge 자체가 오픈소스여야 한다"가 타협 불가 가치로 확정될 때 |
| Backlog.md 채택 | 시범에서 층 ①(handoff)과의 이중 기입이 실제로 발생할 때 · 태스크 ID 참조가 줄 번호보다 나쁘다는 실측이 나올 때 |

---

_2026-08-30 확정. 조사는 3-14 세션 deep-research(에이전트 104개 · 소스 22개 · 주장 110건 → 25건 3표 적대적 검증 → 19건 확정/6건 기각), Gitea 위키 저장 구조와 Backlog.md 검증은 후속 세션에서 소스·실파일로 직접 확인._
_2026-08-30 후속: 최종 검토에서 결정 1번(Gitea) 폐기 · 결정 2번 수정(정본 형태를 `backlog/tasks/*.md`로) · 결정 3번 유효. `Backlog.md` 채택 근거는 이 맥에서 직접 실행해 확인._
