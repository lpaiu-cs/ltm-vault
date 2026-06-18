---
id: system_ingest_policy
title: Ingest Policy
aliases:
  - 인입 정책
  - Ingest Policy
  - Ingestion Workflow
type: System-Specification
moc: "[[Second Brain MOC]]"
parent_moc: "[[Second Brain MOC]]"
tags:
  - System
  - SecondBrain
  - Ingest
status: evergreen
created: 2026-06-18
updated: 2026-06-18
version: 1.0
related:
  - "[[Source Policy]]"
  - "[[Review Policy]]"
  - "[[Second Brain Operating Model]]"
---

> [!IMPORTANT] 목적
> 인입(ingest) 워크플로우를 정의합니다. 미가공물이 어떻게 불변 원본이 되고, 어떻게
> 해석 계층으로 흘러가는지를 단계로 규정합니다. **모든 단계를 매번 다 거칠 필요는
> 없습니다.** 자료의 성격에 맞는 단계만 적용하세요.

---

## 1. 표준 인입 워크플로우 (11단계)

1. **미가공물을 `05_Inbox/`에 둔다.** 성격에 맞는 하위 폴더(`chats/`, `notes/`,
   `screenshots/`, `links/`, `code-logs/`, `admin-records/`)에 떨어뜨린다. 아직
   판단·구조화하지 않아도 된다.
2. **안정적 원본을 `06_Raw/`로 이동/복사한다.** 증거 가치가 있다고 판단되면
   원본에 가깝게 보존한다. **이관 후 raw는 불변**이다([[Source Policy]] §2).
   파일명은 [[Naming Convention]]을 따른다(예: `06_Raw/chats/2026-06-18-topic.md`).
3. **`50_Source_Summaries/`에 source summary를 만든다.** 원본을 압축·구조화하고,
   frontmatter `source_path`로 raw를 가리킨다. 핵심 주장·인용·불확실 지점을 적는다.
4. **관련 `30_Projects/` 대시보드를 갱신한다.** 어떤 프로젝트에 영향을 주는지
   링크하고, 대시보드의 상태/다음 행동을 갱신한다. (덤프 금지, 링크 중심)
5. **내구성 지식일 때만 `20_Concepts/`를 갱신한다.** source가 *지속적으로 유효한*
   개념 지식을 더할 때만 개념을 만들거나 보강한다. (절제 — §2 경고 참조)
6. **중요한 선택이 있으면 `40_Decisions/`에 결정 기록을 만든다.** source가 아키텍처·
   방향·도구 선택 등 중요한 결정을 담고 있으면 decision record로 남긴다([[Review Policy]]·[[Naming Convention]]).
7. **미해결 질문을 `60_Open_Questions/`에 추가한다.** 연구/구현/행정 카테고리에 맞춰
   적는다.
8. **충돌을 `70_Contradictions/`에 추가한다.** 기존 지식과 새 source가 부딪히면
   매끄럽게 덮지 말고 양쪽을 보존한다(이론/출처/낡은 가정).
9. **불확실하거나 의심스러운 출력을 `80_Reviews/`에 추가한다.** 신뢰도 낮음·환각
   의심·사람 판단 필요 항목을 검토 큐에 올린다.
10. **관련 MOC(`10_MOC/`)를 갱신한다.** 새 노드가 어느 지도에 속하는지 링크를 더한다.
11. **인덱싱/동기화를 실행하거나 필요성을 기록한다.** 사람이 직접 편집했으면
    `sync_vault()` 또는 `python3 90_Engine/indexer.py --embed --report`를 실행한다.
    MCP write 도구를 썼으면 자동 정합되며, 즉시 검색이 필요하면 `reconcile_graph(embed=false)`.
    실행 환경이 아니라면 "재인덱싱 필요"를 해당 노트에 TODO로 남긴다.

## 2. ⚠️ 모든 source를 concept node로 바꾸지 말 것

> [!WARNING] Anti-Bloat 경고
> 인입의 가장 흔한 실패는 **모든 원본을 개념 노드로 승격시키는 것**입니다. 그러면
> `20_Concepts/`는 일회성 메모와 휘발성 생각으로 오염되고, 9-predicate 그래프는
> 노이즈로 가득 차 k-hop 확장 시 의미 누수(semantic drift)를 일으킵니다.

규칙:

- 기본 도착지는 **`50_Source_Summaries/`**다. 대부분의 source는 요약까지만 만들면 된다.
- `20_Concepts/` 승격은 source가 **재사용 가능하고 지속적으로 유효한** 개념 지식을
  더할 때만. "이 개념을 다른 맥락에서 또 참조하게 될까?"가 Yes일 때만.
- 같은 개념의 중복 노드가 의심되면 만들지 말고 `80_Reviews/`에 `duplicate-concept-candidate`로 올린다.
- 일시적 연관을 predicate 엣지로 강제하지 않는다([[Ontology Specification]] §4: 불확실하면 비워라).

## 3. 자료 유형별 최소 경로 (실무 단축)

| 자료 | 최소 경로 |
|------|-----------|
| 잡다한 메모 | `05_Inbox/notes/`에만 둔다. 승격 불필요할 수 있음. |
| 디버깅 세션 | `06_Raw/code-logs/` → `50_Source_Summaries/code-logs/` → 프로젝트 대시보드 |
| 논문 | `06_Raw/papers/` → `50_Source_Summaries/papers/` → (필요 시) 개념 보강 |
| 중요한 설계 대화 | `06_Raw/chats/` → 요약 → **`40_Decisions/` 결정 기록** |
| 행정 처리 | `06_Raw/admin-records/` → 요약/`60_Open_Questions/Admin Questions` |

## 4. 인입 체크리스트 (에이전트용)

- [ ] 원본을 `06_Raw/`에 보존했고, 이후 수정하지 않는가?
- [ ] source summary가 `source_path`로 raw를 가리키는가?
- [ ] 중요한 사실 주장에 출처를 달았는가?
- [ ] 개념 승격이 정말 필요한가? (대부분 No)
- [ ] 중요한 선택을 결정 기록으로 남겼는가?
- [ ] 불확실/모순을 `80_Reviews/`·`70_Contradictions/`로 보냈는가?
- [ ] 재인덱싱을 실행했거나 TODO로 남겼는가?

---

## Sources

- 설계 근거: [[2026-06-18-second-brain-architecture]]
- 관련 정책: [[Source Policy]], [[Review Policy]], [[Naming Convention]]
