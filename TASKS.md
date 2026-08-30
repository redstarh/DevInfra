# 작업 원장 — 다중 프로젝트 forge (Gitea)

> **범위**: 여러 프로젝트를 공통으로 관리하는 로컬 forge 구축. 어느 개별 프로젝트에도 속하지 않는다 —
> `OhMyEnglish/TASKS.md` 등 프로젝트별 원장과 별개이고 서로의 상태를 참조하지 않는다.
> **이 파일이 이 작업 상태의 정본이다.**
>
> 조사: `docs/research/2026-08-30-wiki-task-tooling.html` · 결정: `docs/design/2026-08-30-wiki-task-tooling-decision.md`
> 설치 전 브리핑: `docs/design/2026-08-30-gitea-briefing.html`

_최초 작성: 2026-08-30_

---

## 확정된 결정 (2026-08-30)

착수 전 필수 4건이 전부 답을 받았다. **차단 없음.**

| # | 결정 | 결과 |
|---|---|---|
| A | `~/AgentDev`(stock-agent, 커밋 1,049개) | **통합하지 않고 그대로 둔다.** Synology NAS remote 유지, Gitea 편입 대상 아님 |
| B | GitHub에 있는 리포의 정본 | **GitHub에 둔다.** `AllMyEnglish`·`ai-driven-development`는 GitHub이 정본 |
| C | git이 아닌 프로젝트 | **지금 편입한다.** `En-Coach`·`WSEAgent`·`DevInfra` |
| D | 공통 문서의 집 | **`~/MyProject/DevInfra` 신설** (이 리포). `Research`는 흡수 후 폐기 |

**B의 실행 방식** — 정본이 GitHub이므로 **Gitea에 이중화하지 않는다** (Simplicity First). 한 보드에서 전부 보고
싶어지면 pull mirror를 나중에 추가하면 되고, 그것은 되돌리기 쉬운 선택이다. Task 10 참조.

---

## Gitea 편입 대상 — 5개

| 리포 | 현재 상태 | 편입 이유 |
|---|---|---|
| `OhMyEnglish` | git 있음, `.git` 7.3MB, 커밋 107, **remote 없음** | **최우선** — remote가 없어 PR 개념 자체가 성립하지 않는다 |
| `cursor-todo-app` | git 있음, `.git` 0.23MB, 커밋 1, remote 없음 | remote 없음 |
| `En-Coach` | **git 없음**, 소스 ~700KB (74MB는 전부 `.venv`) | 신규 git init |
| `WSEAgent` | **git 없음**, ~350KB (`.gitignore`에 `data/` 등 이미 있음) | 신규 git init |
| `DevInfra` | **git 없음** (이 리포) | 신규 git init |

예상 저장량 합계 **~8.6MB** — A·B 결정으로 큰 두 개(stock-agent 18MB, 외부 클론들)가 빠져 브리핑의 26.6MB보다 줄었다.

### 편입하지 않는 것

- `~/AgentDev` (stock-agent) — 결정 A
- `AllMyEnglish` · `ai-driven-development` — 결정 B (GitHub 정본)
- 남의 리포 클론 3건 (`claude-code-tips` · `ml-intern` · `ai-driven-development-lecture`) — 관리 대상 아님

---

## Task

상태: `대기` / `진행` / `완료`. **완료 전환은 증거 열의 명령을 직접 돌려 출력을 확인한 뒤에만 한다.**

| # | Task | 상태 | 완료 증거 |
|--:|---|---|---|
| 0 | `DevInfra` 신설 + `Research` 내용 이관 | 완료 | 파일 4개 이관 확인 (2026-08-30) |
| 1 | `En-Coach/.gitignore` 보강 — `.venv`·`__pycache__`·`.pytest_cache`·`egg-info` | 대기 | `git status --short` 에 `.venv` 미출현 |
| 2 | `git init` 3개 (`DevInfra`·`En-Coach`·`WSEAgent`) + 최초 커밋 | 대기 | 리포별 `git log --oneline -1` · 커밋에 venv/캐시 없음 |
| 3 | `OhMyEnglish`에서 이관된 문서 2건 `git rm` | 대기 | `git log -1` · 두 곳에 정본이 남지 않음을 확인 |
| 4 | `brew install gitea` | 대기 | `gitea --version` 출력 (현재 미설치 확인됨) |
| 5 | 비밀값 3개 생성 + `app.ini` 작성 — 브리핑의 켤/끌 목록 반영 | 대기 | `app.ini` 내용. **`/tmp/giteatest/`의 조사용 평문 비밀값 재사용 안 함** 확인 |
| 6 | 기동 → HTTP 200 → **유휴 메모리 이 맥에서 실측** | 대기 | `curl -o /dev/null -w '%{http_code}'` = 200 · RSS 20초 간격 3회 · 프로세스 수 1 |
| 7 | 관리자 계정 + Organization 1개 생성 | 대기 | `gitea admin user create --admin` 출력 · org 페이지 200 |
| 8 | 리포 5개 편입 — `OhMyEnglish` 먼저 | 대기 | 리포별 `git push --all` 출력 · Gitea에 커밋 수 일치 |
| 9 | **백업·복구 리허설** — `gitea dump` → 복원 → 이슈 1건 조회 | 대기 | dump 파일 크기 · 복원 후 이슈 조회 성공 출력 |
| 10 | (선택) GitHub 정본 리포 2개를 pull mirror로 추가 | 보류 | 결정 B에 따라 기본은 안 한다 |
| 11 | PR 1건 실제 왕복 — 이슈 → 브랜치 → PR → 라인 코멘트 → merge | 대기 | PR URL · merge 커밋 해시 |
| 12 | 실측 유휴 메모리를 결정 기록에 반영 | 대기 | 결정 문서에 재측정값 커밋 |

**Task 9를 건너뛰지 않는다.** 이슈·PR·리뷰 코멘트는 bare 리포가 아니라 SQLite에만 있다 — 복구를 한 번
돌려보기 전에는 "이슈를 잃지 않는다"고 말할 수 없다.

---

## 미결 · 리스크

- **`En-Coach`에 `app/backend/.env`가 실재한다.** `.gitignore`가 이 한 줄만 덮고 있었다. Task 1에서 나머지를
  보강하되 `.env`가 이미 무시되고 있음을 재확인한다 — 비밀값이 최초 커밋에 들어가면 이력에서 지우기 어렵다.
- **`~/MyProject/Research` 디렉터리가 빈 채로 남아 있다.** 이 세션의 작업 디렉터리라서 지우지 않았다.
  세션 종료 후 `rmdir` 하면 된다.
- **유휴 165MB는 이 맥에서 재측정한 값이 아니다.** 조사 세션(3-14)이 20초 간격 3회로 168,864~169,232KB를
  측정했다. Task 6이 이것을 대체한다.
- **리포 5개 · 이슈가 쌓인 뒤의 메모리를 모른다.** 빈 인스턴스 하한만 안다. bleve 이슈 인덱서가 주 증가
  요인이고, 예산(유휴 ≤512MB)을 위협하면 `ISSUE_INDEXER_TYPE = db`로 내리는 선택지가 있다.
- **`OhMyEnglish`는 다른 세션이 동시에 작업한다.** Task 3·8에서 그 세션의 브랜치 상태와 충돌하지 않게 시점을 맞춘다.
- **Actions·Packages는 기본이 on이다.** Task 5에서 명시적으로 끄지 않으면 켜진 채로 뜬다 (`modules/setting/actions.go:47`).

## 결정 기록 (뒤집힌 것 포함)

| 날짜 | 결정 | 상태 |
|---|---|---|
| 2026-08-30 | 위키 도구를 세우지 않고 Gitea 리포 브라우저의 `docs/**.md` 렌더링으로 대체 | 유효 |
| 2026-08-30 | 태스크 상태의 정본은 프로젝트별 `TASKS.md` 유지 — Gitea 이슈는 버그·PR 트래킹 전용 | 유효 |
| 2026-08-30 | Backlog.md는 제약을 만족하나 인계 규약(`TASKS.md:줄번호`) 때문에 보류 | 유효 |
| 2026-08-30 | ~~"Gitea Wiki로 리포 `docs/`를 위키 정본 삼기"를 확인해볼 가치가 있다~~ → **기각.** 별도 `<repo>.wiki` 리포가 정본이고 설정이 없다 (`models/repo/wiki.go:74`, `gitea#23640` open) | 뒤집힘 |
| 2026-08-30 | 용도를 단일 프로젝트(OhMyEnglish)에서 **다중 프로젝트 공통**으로 확장 | 유효 |
| 2026-08-30 | ~~공통 문서를 `OhMyEnglish/docs/`에 둔다~~ → **`DevInfra` 신설로 이관** | 뒤집힘 |
