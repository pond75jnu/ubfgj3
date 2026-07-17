# UBF 광주 3부 수양회 관리 웹사이트


## 주요기능

- 수양회비 등록 관리
- 수입, 지출 관리
- 자동 정산 등

## 개발 기준

- 모든 페이지는 모바일 우선으로 구현하고 320px·390px 화면 폭에서 가로 넘침과 터치 조작을 확인한다.
- `.aspx`, `.cs` 파일은 UTF-8 with BOM 및 CRLF로 저장한다.
- Stored Procedure를 변경하면 `DB/StoredProcedure`의 개별 스크립트와 `All_SP_LIST.sql`을 함께 갱신하고 실제 DB에도 반영한다.
