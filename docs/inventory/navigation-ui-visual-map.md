# Navigation UI 시각 지도

이 문서는 Navigation UI의 현재 문제, Routex Design System의 규칙 구조, 저장소별 소유권과
적용 순서를 빠르게 공유하기 위한 시각 색인이다. 수치와 판정 근거의 단일 출처는
[Navigation UI inventory](./navigation-ui-inventory.md)다.

## 1. 현재 UI 문제 지도

```mermaid
flowchart TB
    Current["현재 Navigation UI<br/>화면이 값을 직접 결정"]

    Current --> Sheet["시트 구조<br/>handle · header · body · action 불일치"]
    Current --> Rhythm["여백과 리듬<br/>screen · section · component · sibling 혼재"]
    Current --> Radius["곡률<br/>크기와 역할 없이 개별 지정"]
    Current --> Type["타이포그래피<br/>크기 · 굵기 · baseline 직접 지정"]
    Current --> State["상태 문법<br/>selected · loading · empty · error 불일치"]
    Current --> Layer["지도 위 깊이<br/>surface · stroke · elevation 순서 불명확"]

    Sheet --> Result["결과<br/>같은 기능이 다른 위계로 보임"]
    Rhythm --> Result
    Radius --> Result
    Type --> Result
    State --> Result
    Layer --> Result
```

## 2. 규칙이 내려오는 순서

화면이 primitive 값을 직접 고르지 않는다. 아래 단계에서 바로 위 단계의 의미를 조합한다.

```mermaid
flowchart LR
    Foundation["Foundation<br/>primitive color · type scale<br/>4px grid · duration"]
    Semantic["Semantic Token<br/>content · surface · action<br/>status · layer · motion role"]
    Core["Core Component<br/>Button · IconButton · Surface · ListCell<br/>Sheet · Status · SearchField · Chip"]
    Pattern["Product Pattern<br/>MapTopBar · SearchPanel · CategorySheet<br/>ETA · RouteInstruction"]
    Screen["Navigation Screen<br/>지도와 업무 상태 조합"]

    Foundation --> Semantic --> Core --> Pattern --> Screen
```

규칙을 건너뛰는 의존은 허용하지 않는다.

```mermaid
flowchart LR
    Screen["Screen"] -. "금지: raw color · radius · TextStyle" .-> Foundation["Foundation"]
    Pattern["Product Pattern"] -. "금지: package 내부 지도·API 의존" .-> Map["Map / API domain"]
    Core["Core Component"] -. "금지: Navigation 업무 상태" .-> Domain["Navigation domain"]
```

## 3. 저장소와 모션 소유권

```mermaid
flowchart TB
    Shared["routex_design_system<br/>Runtime Kit + Showcase"]
    Navigation["Navigation"]
    Promo["Promo Studio"]

    Shared --> SharedOwn["공통 token<br/>제품 component motion<br/>핵심 component"]
    Navigation --> NavOwn["지도 paint · POI/노선색<br/>camera · PDR · 제품 조합"]
    Promo --> PromoOwn["프로모 카메라 이동 · particle<br/>timeline · 장면 연출 · 영상 asset"]

    SharedOwn -->|"release tag import"| Navigation
    SharedOwn -->|"공통 token만 사용"| Promo
    PromoOwn -. "패키지 반입 금지" .-> Shared
    NavOwn -. "패키지 반입 금지" .-> Shared
```

## 4. 런타임에서 확인한 상태

```mermaid
flowchart LR
    Outdoor["외부 지도"] --> Menu["메뉴"]
    Outdoor --> Search["일반 검색<br/>loading → 결과"]
    Outdoor --> Directions["길찾기<br/>자동차 · 대중교통 · 도보"]
    Search --> Detail["장소 상세<br/>bookmark · 출발 · 도착"]
    Outdoor --> Category["카테고리<br/>소분류 · 목록"]
    Category --> Detail
    Outdoor --> Indoor["실내 B1<br/>층 선택"]
    Indoor --> PDR["PDR 버튼<br/>센서 권한 실패"]
    Menu --> Favorites["즐겨찾기<br/>빈 상태"]
    Menu --> Calibration["위치 보정<br/>실패 피드백"]
    Menu --> Debug["디버그 off/on<br/>진단 layer"]

    Directions -. "현재 위치 없음" .-> Blocked["실제 경로 안내 · 도착<br/>미확인"]
    Detail -. "목록 반영 없음" .-> SaveCheck["저장 흐름<br/>별도 기능 점검"]
```

## 5. v0.1 적용 순서

```mermaid
flowchart LR
    I["1. Inventory<br/>완료"] --> T["2. Token 결정"]
    T --> C["3. Core 8<br/>proposal → beta"]
    C --> S["4. Showcase<br/>실제 package import"]
    S --> P1["5. Pilot 1<br/>AppMenuSheet"]
    P1 --> P2["6. Pilot 2<br/>FavoritesSheet"]
    P2 --> R["7. v0.1.0<br/>release tag"]
    R --> N["8. Navigation<br/>호환 wrapper로 점진 교체"]
```

단계별 통과 조건은 inventory의
[pilot 선정](./navigation-ui-inventory.md#8-pilot-선정)과
[다음 token PR의 결정 항목](./navigation-ui-inventory.md#9-다음-token-pr의-결정-항목),
[v0.1 foundation token 계약](../decisions/0001-foundation-tokens.md)을 따른다.
