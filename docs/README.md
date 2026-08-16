# 문서 안내

이 디렉터리는 현재 구현의 계약과 Navigation 적용 결정을 기록한다. 구현 목록은 소스와 테스트가
단일 출처이며, 문서에는 코드에서 읽을 수 없는 책임 경계·실패 기준·이관 절차만 둔다.

## 읽는 순서

| 문서 | 단일 출처인 내용 |
|---|---|
| [시스템 계약](system-contract.md) | 저장소 구조, 계층, 공개 API 상태, 품질·실패 기준 |
| [Navigation UI 조사](inventory/navigation-ui-inventory.md) | 원본 앱 기준선과 포팅 위험 지점 |
| [제품 결정](place-detail-guidance-decisions.md) | 장소 상세·검색·시트·안내의 최종 UX 결정 |
| [원본 앱 포팅 가이드](navigation-app-porting-guide.md) | 원리, 단계, 파일별 연결법, 엄격한 중단 기준 |
| [0001 Foundation token](decisions/0001-foundation-tokens.md) | semantic token 계층 결정 |
| [0002 시각 값 계약](decisions/0002-visual-source-contract.md) | 현재 디자인을 바꾸지 않고 시스템화하는 결정 |

## 문서 운영 규칙

- 현재 컴포넌트 목록과 API는 package barrel과 package README를 기준으로 한다.
- 검증 명령과 Showcase 사용법은 각 앱 README를 기준으로 한다.
- 과거 계획, 완료된 단계별 작업표, 정적 HTML 카탈로그는 보관하지 않는다. 이력이 필요하면 Git을
  조회한다.
- 같은 사실을 여러 문서에 복사하지 않고 위 표의 단일 출처로 링크한다.
- Navigation 코드 조사 결과에는 확인한 commit을 적는다. 원본이 바뀌면 포팅 전에 다시 조사한다.
