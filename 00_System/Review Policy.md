---
id: system_review_policy
title: Review Policy
aliases:
  - 검토 정책
  - Review Policy
type: System-Specification
moc: "[[Second Brain MOC]]"
parent_moc: "[[Second Brain MOC]]"
tags:
  - System
  - SecondBrain
  - Review
status: evergreen
created: 2026-06-18
updated: 2026-06-18
version: 1.0
related:
  - "[[Second Brain Operating Model]]"
  - "[[Ingest Policy]]"
---

> [!IMPORTANT] 목적
> LLM 출력이 틀릴 수 있다는 전제([[Hallucination as Default]]) 아래, 의심스럽거나
> 미해결인 항목을 **사람 검토 큐**로 라우팅하고 추적하기 위한 카테고리와 상태(status)를
> 정의합니다. `80_Reviews/`와 `70_Contradictions/`가 이 정책의 운영 대상입니다.

---

## 1. 검토 카테고리 (Review Categories)

| 카테고리 | 키 | 의미 | 기본 도착지 |
|----------|-----|------|-------------|
| 사람 검토 필요 | `needs-human-review` | 자동 판단 불가, 사람의 결정/확인 필요 | `80_Reviews/Needs Human Review.md` |
| 낮은 신뢰도 | `low-confidence` | 주장은 가능하나 근거/확신이 약함 | `80_Reviews/Low Confidence Claims.md` |
| 환각 의심 | `possible-hallucination` | 출처 없이 그럴듯한 사실처럼 보이는 주장 | `80_Reviews/Possible Hallucinations.md` |
| 출처 충돌 | `source-conflict` | 서로 다른 source가 상충 | `70_Contradictions/Source Conflicts.md` |
| 낡은 가정 | `stale-assumption` | 과거엔 맞았으나 지금은 의심스러운 전제 | `70_Contradictions/Stale Assumptions.md` |
| 중복 개념 후보 | `duplicate-concept-candidate` | 같은 개념의 중복 노드 가능성 | `80_Reviews/Needs Human Review.md` |
| 결정 재고 필요 | `decision-needs-reconsideration` | 기존 결정의 전제가 흔들림 | `80_Reviews/Needs Human Review.md` (+ 해당 결정 링크) |

> 이론 자체의 정면 충돌은 `70_Contradictions/Theory Conflicts.md`에 보존합니다.

## 2. 상태 (Statuses)

| status | 의미 |
|--------|------|
| `open` | 큐에 올라왔고 아직 검토되지 않음 (기본값) |
| `reviewed` | 사람이 확인했으나 아직 조치/결론 미정 |
| `resolved` | 해결됨(반영 완료). 무엇을 어떻게 했는지 기록 |
| `rejected` | 검토 결과 유효하지 않음(거짓 양성). 사유 기록 |
| `superseded` | 더 나은 항목/결정으로 대체됨. 대체 대상 링크 |

상태 전이 예: `open → reviewed → resolved` / `open → reviewed → rejected` /
`open → superseded`.

## 3. 검토 항목 형식 (Item format)

각 검토 파일은 항목 목록입니다. 권장 항목 형태:

```markdown
### [open] bge-m3가 모든 도메인에서 최적이라는 주장
- reason: low-confidence
- created: 2026-06-18
- claim: "bge-m3 임베딩이 코드 검색에서도 최적이다."
- source: 06_Raw/project-logs/2026-06-18-embedding-eval.md (코드 검색은 미측정)
- related: [[LLM Second Brain]]
- note: 코드 청크 대상 별도 평가 전까지 단정 금지.
```

- 파일 단위 frontmatter는 [[Naming Convention]]의 review 템플릿을 따른다.
- 항목의 `reason`은 §1 카테고리 키 중 하나, `status`(`[open]` 등)는 §2를 쓴다.
- 해결 시 항목을 지우지 말고 status를 바꾸고 처리 내용을 남긴다(감사 추적 보존).

## 4. 라우팅 규칙 (Routing)

- 출처를 댈 수 없는 사실 주장 → `possible-hallucination`.
- 출처는 있으나 확신이 약함 → `low-confidence`.
- 서로 다른 source가 부딪힘 → `source-conflict` (→ `70_Contradictions/`).
- 두 이론/철학이 양립 불가 → `70_Contradictions/Theory Conflicts.md`.
- 기존 결정의 전제가 무너짐 → `decision-needs-reconsideration` + 해당 `40_Decisions/` 링크.
  결정이 실제로 바뀌면 [AGENTS.md](../AGENTS.md) §4의 supersede 절차를 따른다.

---

## Sources

- 설계 근거: [[2026-06-18-second-brain-architecture]]
- 관련 개념: [[Hallucination as Default]], [[Reflection Loop]]
- 관련 정책: [[Ingest Policy]], [[Naming Convention]]
