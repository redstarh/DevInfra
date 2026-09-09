---
name: h-doc
description: Use when writing, reviewing, or scoping anything for the OhMyEnglish project or any English-learning content for this user — design docs, spec edits, curriculum, session prompts, TTS questions, example sentences, correction feedback, review or shadowing material, difficulty decisions. Also use when a request silently assumes the user's English level, learning requirements, or target level.
---

# h-doc — 학습자 프로필 정본

단일 사용자(캡틴)의 영어 수준·학습 요구사항·목표 수준. **문구 스타일과 난이도의 SoT다.**

**구현 범위는 이 skill이 정하지 않는다.** 범위·아키텍처의 정본은 프로젝트 저장소 문서다 — 현재 정본: `~/MyProject/OhMyEnglish` (`docs/PRD.md`, `docs/design/`, `handoff/HANDOFF.md`).
(2026-08-25 정정: 이전 버전이 가리키던 `~/MyProject/AllMyEnglish`는 진행하다 만 프로젝트로 폐기됐다. 고려하지 마라.)

## 현재 수준

- 하루 일상을 간단한 문장으로 얘기할 수 있음
- 간단한 인사와 small talk 가능한 수준
- `I want to` / `I need to` / `I'd like to` 등 간단한 패턴으로 단문 위주로 얘기함
- 일상 단어는 이해하고 들을 수 있음

## 학습 요구사항

- 반복적으로 틀리는 구문·문법을 학습 패턴으로 기억하여, 비슷한 구문을 계속 학습해 지속 향상
- Speaking이 주가 되는 학습 패턴
- 주간·월간 학습 패턴을 분석해 틀리는 구문을 재학습하도록 제시
- 쉐도잉 기능
- 필요시 유투브 영상 수집
- 자주 틀리는 분석 내용을 확인하고, 해당 패턴으로 요청해서 학습을 만들 수 있는 기능

## 목표 수준

- 간단한 회사 수준에서 점진적으로 높여, 사내 비즈니스 미팅 참여·보고 가능
- IT 회사 프로젝트를 리딩하고 설명할 수 있는 수준
- AWS에서 Engage Manager로 프로젝트 상황을 보고 가능

## 적용 규칙

| 상황 | 이 프로필이 정하는 것 |
|------|----------------------|
| 예문·질문·프롬프트 생성 | 단문·단일 절 기준. 위 3개 패턴을 발판으로 쓰되 거기 고착시키지 말고 확장형을 조금씩 얹는다 |
| 교정 대상 우선순위 | 긴 문장·시제·어순·자연스러운 비즈니스 표현·즉흥 발화 (OhMyEnglish `PRD.md` §7 오류 분류와 일치) |
| 모드 선택 | Speaking 우선. 읽기·쓰기 전용 기능은 이 프로필로 정당화되지 않는다 |
| 난이도 상향 경로 | 일상 → 업무 협업 → 프로젝트 리딩 → AWS 보고 (OhMyEnglish `PRD.md` §7 Business English 단계와 일치) |
| 새 주제 vs 재학습 | 반복 오류의 유사 구문 재등장이 핵심 루프다. 새 주제 추가보다 재학습이 앞선다 |

## 범위 질문이 오면

이 프로필로 기능의 포함/제외를 판정하지 마라 — 프로젝트 문서로 보내라. 참고로 이전 버전이 "스펙에 없음(❌)"으로 판정했던 3건(월간 분석, YouTube 영상 추천, 오류 패턴 지정 요청형 학습)은 그 판정 근거가 폐기된 AllMyEnglish 스펙이었고, **OhMyEnglish는 셋 다 범위에 포함한다** (`HANDOFF.md`·`docs/requirements-summary.md`). 다만 어느 것도 첫 수직 슬라이스에는 없다 — 단계 배치는 `docs/design/` 설계서가 정한다.

## 흔한 실수

- **목표 수준을 현재 수준으로 착각** — AWS 보고 수준 문형으로 예문을 만들면 첫 세션에서 얼어붙는다.
- **고정 수치 발명** — 정답 N회·맥락 N개 같은 수치를 이 프로필에서 만들어내지 마라. 문서에 근거가 있는 수치(예: 복습 1·3·7일 — `OhMyEnglish/handoff/HANDOFF.md`)만 쓰고, 설계가 새 수치를 정할 땐 발명임을 명시한다.
- **프로필을 근거 없이 갱신** — 수준·목표 변경은 캡틴 발화가 근거여야 한다. 세션 중 추정으로 고치지 않는다.
- **이 프로필로 범위 판정** — 위 "범위 질문이 오면" 참조.
