---
id: system_source_policy
title: Source Policy
aliases:
  - 출처 정책
  - Source Policy
type: System-Specification
moc: "[[Second Brain MOC]]"
parent_moc: "[[Second Brain MOC]]"
tags:
  - System
  - SecondBrain
  - Source
status: evergreen
created: 2026-06-18
updated: 2026-06-18
version: 1.0
related:
  - "[[Second Brain Operating Model]]"
  - "[[Ingest Policy]]"
---

> [!IMPORTANT] 목적
> 무엇이 **source(원본·증거)**인지 정의하고, 원본을 어떻게 보존하며, 해석 계층의
> 주장이 어떻게 원본을 가리켜야 하는지를 규정합니다. 이 정책은 시스템이
> "근거 없는 LLM 기억 그래프"로 퇴화하는 것을 막는 1차 방어선입니다.

---

## 1. source로 인정되는 것 (What counts as a source)

다음은 모두 source이며 `06_Raw/`에 보존 대상입니다.

| source 유형 | 설명 | 권장 위치 |
|-------------|------|-----------|
| 채팅 로그 (chat logs) | LLM/사람과의 대화 원문 | `06_Raw/chats/` |
| 코드 diff (code diffs) | 변경 전후 패치, 커밋 diff | `06_Raw/code-logs/` |
| 에러 로그 (error logs) | 스택트레이스, 런타임 출력 | `06_Raw/code-logs/` |
| 논문 (papers) | PDF, 발췌, 메타데이터 | `06_Raw/papers/` |
| 스크린샷 (screenshots) | 이미지 + 캡션/OCR | `06_Raw/screenshots/` |
| 프로젝트 로그 (project logs) | 실험 기록, 실행 로그, 회의록 | `06_Raw/project-logs/` |
| 행정 기록 (administrative records) | 일정, 비용, 계정, 절차 기록 | `06_Raw/admin-records/` |
| 수기 노트 (manual notes) | 사람이 직접 적은 메모(확정본) | `06_Raw/` (성격에 맞는 하위 폴더) |
| 링크 (links) | URL + 접근 시점 + 인용 스냅샷 | `06_Raw/` 또는 요약에 URL 기재 |

> 인입 직후의 휘발성 자료는 먼저 `05_Inbox/`에 둡니다. **안정적으로 증거 가치가
> 있다고 판단될 때만** `06_Raw/`로 이관합니다. 이관 절차는 [[Ingest Policy]] 참조.

## 2. 규칙 (Rules)

1. **source 파일은 증거다.** 증거는 검증·재현·감사를 위한 것이며, 신뢰의 최종
   기준점이다.
2. **source는 원본에 최대한 가깝게 보존한다.** 실무상 가능한 범위에서 원문을 그대로
   둔다. 형식 변환이 불가피하면(예: PDF→텍스트 발췌) 변환 사실과 손실 가능성을
   요약 노트에 기록한다.
3. **LLM이 생성한 요약은 source가 아니다.** 요약·해석·재서술은 `50_Source_Summaries/`
   또는 해석 계층(`20`/`30`/`40`)에 두며, 절대 `06_Raw/`에 섞지 않는다.
4. **해석 계층의 주장은 가능하면 source를 가리킨다.** 중요한 사실 주장에는 source
   경로(`06_Raw/...` 상대 경로)나 외부 URL을 함께 적는다. 가리킬 source가 없으면
   "에이전트 추론"임을 명시하거나 [[Review Policy]]에 따라 `80_Reviews/`로 보낸다.
5. **`06_Raw/`는 불변이다.** 이관이 끝난 raw 파일은 수정·삭제하지 않는다. 잘못된
   해석은 raw가 아니라 요약/개념을 고쳐 바로잡는다. (강제 규칙: [AGENTS.md](../AGENTS.md) §1.1)

## 3. source 인용 형식 (Citation format)

해석 노트 본문에서 권장하는 인용 형태:

```markdown
- 주장: bge-m3 임베딩이 한국어/영어 혼합 쿼리에서 잘 동작함.
  근거: [[Source Summary — 2026-06-18-embedding-eval]] (원본: 06_Raw/project-logs/2026-06-18-embedding-eval.md)
```

- 내부 노트 참조는 wikilink `[[...]]`, 원본 증거 참조는 **상대 경로**를 쓴다.
- source-summary node는 frontmatter `source_path`로 raw 원본을 가리킨다([[Naming Convention]]).

## 4. source가 아닌 것 (Not a source)

- LLM/에이전트가 새로 생성한 요약·종합·결론 (→ 해석 계층)
- MOC, 개념 페이지, 프로젝트 대시보드, 결정 기록 (→ 해석 계층)
- 검토 큐 항목, 모순 기록 (→ 메타 계층)

이들은 모두 source를 **가리킬 수는 있어도** source 자체는 아닙니다.

---

## Sources

- 설계 근거: [[2026-06-18-second-brain-architecture]]
- 관련 정책: [[Ingest Policy]], [[Review Policy]], [[Naming Convention]]
