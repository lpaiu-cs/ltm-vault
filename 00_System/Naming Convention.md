---
id: system_naming_convention
title: Naming Convention
aliases:
  - 명명 규칙
  - Naming Convention
  - File Naming
type: System-Specification
moc: "[[Second Brain MOC]]"
parent_moc: "[[Second Brain MOC]]"
tags:
  - System
  - SecondBrain
  - Naming
status: evergreen
created: 2026-06-18
updated: 2026-06-18
version: 1.0
related:
  - "[[Second Brain Operating Model]]"
  - "[[Ontology Specification]]"
---

> [!IMPORTANT] 목적
> 계층별 파일 명명 규칙과 권장 YAML frontmatter를 정의합니다. 원칙: **불투명한 ID보다
> 사람이 읽을 수 있는 이름을 쓴다.** 단, 엔진이 내부적으로 ID를 요구하는 경우(예:
> `node_id` UUID)는 frontmatter에 유지한다.

---

## 1. 공통 원칙

- 파일명에 허용: 영문/숫자/공백/언더바/하이픈/한글. 금지: `\ / : * ? " < > |`.
- concept/MOC node의 파일명 stem은 곧 wikilink 식별자다(예: `[[Transformer]]`).
- raw·summary·decision 등 아카이브성 파일은 **날짜 접두사**로 정렬·추적성을 확보한다.
- 약어/풀네임 중 하나를 메인으로 고정하고 나머지는 frontmatter `aliases`로 둔다.

## 2. 계층별 명명 규칙

| 계층 | 형식 | 예시 |
|------|------|------|
| raw 채팅 | `YYYY-MM-DD-topic.md` | `06_Raw/chats/2026-06-18-mcp-debug.md` |
| raw 기타 | `YYYY-MM-DD-topic.md` | `06_Raw/papers/2017-06-12-attention-is-all-you-need.md` |
| source summary | `Source Summary — YYYY-MM-DD-topic.md` | `50_Source_Summaries/chats/Source Summary — 2026-06-18-mcp-debug.md` |
| decision record | `YYYY-MM-DD-short-kebab-title.md` | `40_Decisions/2026-06-18-second-brain-architecture.md` |
| project page | `Title Case 명사구.md` | `30_Projects/LLM Second Brain.md` |
| concept page | `명사형 단일 엔티티.md` | `20_Concepts/Transformer.md` |
| MOC | `… MOC.md` (` MOC` 접미사) | `10_MOC/Development MOC.md` |
| contradiction | `주제 Conflicts.md` / 영역 파일 | `70_Contradictions/Theory Conflicts.md` |
| review | `상태/유형 이름.md` | `80_Reviews/Low Confidence Claims.md` |

> source summary 파일명은 길어도 됩니다. 가독성 우선. wikilink로 참조할 땐
> `[[Source Summary — 2026-06-18-mcp-debug]]`처럼 stem 전체를 씁니다.

## 3. 권장 YAML Frontmatter

### 3.1 decision record

```yaml
---
type: decision
date: 2026-06-18
status: active
project: LLM Second Brain
confidence: medium
sources: []
related:
  - "[[LLM Second Brain]]"
---
```

상태 값: `active` | `superseded` | `rejected`. supersede 시 절차는 [AGENTS.md](../AGENTS.md) §4.

### 3.2 project page

```yaml
---
type: project
status: active
updated: 2026-06-18
area: second-brain
related:
  - "[[Second Brain Operating Model]]"
---
```

### 3.3 source summary

```yaml
---
type: source-summary
source_type: chat
source_path: ../../06_Raw/chats/example.md
created: 2026-06-18
confidence: medium
---
```

`source_type`: `chat` | `paper` | `code-log` | `screenshot` | `project-log` 등.
`source_path`: summary 파일 위치 기준 raw 원본 상대 경로.

### 3.4 review item (파일 단위)

```yaml
---
type: review
status: open
created: 2026-06-18
reason: low-confidence
related: []
---
```

`reason`: [[Review Policy]] §1 카테고리 키. `status`: 같은 문서 §2.

### 3.5 concept / MOC (기존 컨벤션 유지)

기존 `20_Concepts/`·`10_MOC/` node는 현행 frontmatter(`id`, `title`, `aliases`,
`type`, `moc`, `tags`, `status`, `created`, `node_id` 등)를 유지한다. 인덱서가
사용하는 키는 `title`·`aliases`·`type`·`moc`이며, 나머지는 무시되어도 안전하다.

## 4. ID에 대하여

- 사람이 읽는 이름을 기본으로 한다.
- `node_id`(UUID)는 인덱서가 발급/보존하는 **엔진 내부 식별자**다. 사람이 손으로
  바꾸지 않는다.
- decision record의 날짜 접두사는 ID 겸 정렬 키 역할을 하며, 충돌 시 같은 날짜에
  `-2` 등 접미사를 붙인다(예: `2026-06-18-foo-2.md`).

---

## Sources

- 설계 근거: [[2026-06-18-second-brain-architecture]]
- 기존 파일명 4대원칙: [[Karpathy LLM Framework MOC]] §6.2
- 관련: [[Ontology Specification]], [[Review Policy]]
