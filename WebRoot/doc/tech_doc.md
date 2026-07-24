# UBF 광주 3부 수양회 관리 웹사이트

이 프로젝트는 `UBF 광주 3부` 단체의 수양회 정보, 참석자, 회비 납부, 수입·지출, 회원 권한을 관리하는 ASP.NET Web Forms 웹사이트이다. Visual Studio Web Site 방식으로 구성되어 있어 `.csproj` 없이 `.aspx`, `.aspx.cs`, `App_Code`, `Web.config`를 IIS/IIS Express가 직접 컴파일한다.

## 빠른 파악

- 기술 스택: ASP.NET Web Forms, C#, .NET Framework 4.x, Forms Authentication, ASP.NET Membership/Role Provider, SQL Server
- 주요 DB: `ubfgj3` SQL Server 데이터베이스
- 핵심 기능: 수양회 공지, 회원가입/승인, 요회 관리, 참석자/회비 입력, 실무자 확인, 수입·지출/영수증 관리, 현황/엑셀/인쇄
- 인증 방식: `Web.config`의 Forms Auth와 `SqlMembershipProvider`, `SqlRoleProvider`
- 메뉴/접근권한: DB 테이블 `menu_master`가 결정하며 `usercontrol/top_nav.ascx.cs`에서 렌더링과 권한 차단을 수행
- 활성 수양회 기준: `retreat_master.retreat_yn = 'Y'` 중 `seq DESC` 첫 건. 없으면 일부 헬퍼에서 최신 수양회를 fallback으로 사용
- 공개 URL 정책: 브라우저에 노출되는 내부 URL은 `.aspx` 확장자를 생략한 extensionless URL을 canonical로 사용한다.

## 현재까지 작업 내역

2026-06-29 기준으로 완료된 마이그레이션과 UI 정비 내역이다.

### 등록현황 미등록 포함 여부 선택 (2026-07-24)

- `/staff/status`의 등록현황 탭에 `미등록 제외`, `미등록 포함` 가로형 선택 옵션을 추가했다.
- 기본값은 `미등록 제외`이며, 선택값은 전체 및 각 요회별 등록 통계에 동일하게 적용된다.
- `SP_status_regist_get_members`의 `@INCLUDE_UNREGISTERED BIT = 0` 파라미터가 납부액이 없거나 `0원 이하`인 미등록 구성원의 포함 여부를 결정한다.

### 1. Bootstrap 제거 및 Tailwind 로컬 CSS 전환

- `migration_plan.md`의 방향대로 Bootstrap 기반 공통 레이아웃을 Tailwind 기반 구조로 전환했다.
- `WebRoot/master/master_main.master`에서 Bootstrap CSS/JS와 Bootstrap Icons 의존 로드를 제거했다.
- Tailwind CDN 런타임은 사용하지 않고, `DESIGN.md` 기준 토큰으로 생성한 로컬 CSS `WebRoot/common/css/tailwind.css`를 로드한다.
- 현재 공통 CSS/JS 캐시 버전은 `tailwind.css?v=tailwind-02`, `custom.css?v=tailwind-52`, `custom.js?v=tailwind-25`이다.
- Pretendard GOV 고정(static) dynamic subset 웹폰트를 사용한다.
- `custom.css`는 `DESIGN.md`의 Action Blue, hairline border, neutral background, restrained radius 원칙을 기준으로 공통 화면을 보정한다.
- Web Forms 기존 화면에 남아 있는 `btn`, `form-control`, `form-select`, `table`, `card`, `badge`, `alert` 계열 클래스는 공통 CSS에서 호환 스타일로 흡수한다.
- `custom.js`의 동적 구성원 테이블 버튼/입력도 `site-button`, `ui-input`, `ui-select` 계열로 맞춰 Bootstrap 없이 동작하도록 정리했다.

### 2. 공통 레이아웃과 메뉴 정비

- `master_main.master`는 `top_nav`, `page_header`, `ContentPlaceHolder`, `footer` 순서의 단순한 shell 구조로 정리했다.
- 전역 좌측 rail/aside는 현재 사용하지 않는다. 본문과 좌측 영역이 겹치는 문제를 피하기 위해 메인 shell은 전체 폭 컨테이너를 기준으로 둔다.
- 상단 메뉴는 `usercontrol/top_nav.ascx`와 `top_nav.ascx.cs`에서 `site-nav-*` 구조로 렌더링한다.
- UBF 로고 이미지는 `/common/images/ubf-logo-blue.jpg`로 저장해 브랜드 영역에 사용한다.
- 모바일에서는 햄버거 버튼으로 메뉴를 열고 닫는다.
- 하위 메뉴 dropdown은 마우스 오버가 아니라 클릭할 때만 열린다.
  - CSS는 `.site-nav-dropdown.is-open > .site-nav-dropdown-menu` 상태만 표시한다.
  - `custom.js`는 dropdown toggle 클릭 시 `.is-open`을 토글하고, 바깥 클릭 또는 `Escape` 입력 시 닫는다.
- 로그인한 `admin`, `manager`는 상단 메뉴 우측 계정 영역에서 `수양회 전환` 버튼을 볼 수 있다.
  - 버튼은 강조 색상과 `↔` 아이콘을 사용하되, 크기와 형태는 로그아웃 버튼 계열에 맞췄다.
  - 클릭하면 모달 팝업이 열리고 수양회 목록에서 선택한 수양회를 현재 사용 수양회로 전환한다.

### 3. 디자인 밀도와 폼 크기 조정

- 2880x1800 해상도, 배율 200% 환경에서 화면이 과하게 크고 투박해 보이는 문제를 기준으로 공통 UI 밀도를 낮췄다.
- 주요 입력 컨트롤은 기본 높이 38px, 모바일/브라우저 확대 대응용 14px 계열 폰트로 조정했다.
- `textarea`는 기본 88px 높이로 낮췄고, 버튼은 38px 높이와 4px radius를 기준으로 정리했다.
- 테이블은 14px 폰트, 9px 세로 padding, hairline border 중심으로 정리해 업무 화면에서 정보 밀도가 유지되도록 했다.
- `.container`, `.site-container`, `.site-shell` 계열의 좌우 padding을 데스크톱 48px, 태블릿 24px, 모바일 16px 기준으로 맞췄다.
- cards/panels는 과한 그림자 없이 8px radius와 neutral border를 기본으로 한다.

### 4. 공개 메인 화면 개선

- `Default.aspx`의 첫 화면을 기존 `bg-parchment` 영역에서 `site-home-*` 전용 구조로 교체했다.
- `/common/images/retreat-hero-lively-sky.svg`를 추가하고, 파스텔 석양 하늘·부드러운 구름·햇빛·새를 형상화한 일러스트 hero 배경으로 사용한다.
- 홈 hero에는 배경 이동, 느린 구름 흐름, 빛 번짐, 새 이동 애니메이션을 적용하되, `prefers-reduced-motion` 환경에서는 애니메이션을 끈다.
- 홈 hero에는 blue overlay를 적용해 배경 이미지 위에서도 수양회 제목과 설명이 읽히도록 했다.
- hero 세로 높이는 데스크톱 기준 약 250px, 모바일 기준 약 225px로 줄여 첫 화면이 과하게 높아지지 않도록 했다.
- 장소/기간, 수양회비 영역은 2열 utility card로 배치하고 모바일에서는 1열로 쌓이게 했다.
- 홈 CTA `프로그램 세부보기` 버튼은 공통 compact button 크기와 맞췄고, 클릭 시 PDF 안내 파일을 다운로드하지 않고 모달 내 브라우저 PDF 뷰어로 표시한다.
- 프로그램 PDF 모달은 데스크톱에서 헤더 드래그 이동과 가장자리/모서리 크기 조절을 지원한다.
- 프로그램 PDF 모달은 데스크톱에서 상단 헤더를 더블클릭하면 화면을 꽉 채우고, 다시 더블클릭하면 이전 크기와 위치로 복원한다.

### 5. 검증 결과와 제약

- 로컬 IIS Express 기준 `http://localhost:5000/` 응답 200을 확인했다.
- Chrome headless에서 1440x900, DPR 2 기준으로 홈 화면을 확인했다.
  - hero height: 250px
  - horizontal overflow: 없음
  - background image: `/common/images/retreat-hero-sky-clouds.png` 적용됨
- Chrome headless에서 390x900, DPR 2 모바일 화면을 확인했다.
  - hero height: 225px
  - horizontal overflow: 없음
- 확인용 스크린샷은 `.screenshots/home-hero/` 아래에 저장되어 있다.
- `dotnet build .\ubfgj3.slnx`는 실패한다. 이 프로젝트는 ASP.NET Web Site 형식이라 .NET SDK 빌드가 아니라 .NET Framework 버전 MSBuild/Visual Studio/IIS Express의 ASP.NET 컴파일러가 필요하다.
- 작업 문서에는 DB, SMTP, 로그인 계정, 비밀번호 같은 민감값을 기록하지 않는다.

### 6. 아직 주의할 점

- Bootstrap 배포 CSS/JS 자산은 제거했다. 단, 기존 Web Forms 화면의 `btn`, `form-control`, `table`, `card`, `badge`, `alert` 같은 Bootstrap 계열 클래스명은 호환 스타일 대상으로 공통 CSS에 일부 남아 있다.
- 기존 Web Forms 화면은 서버 컨트롤과 동적 HTML 생성이 섞여 있으므로 신규 화면을 만들 때는 `site-*`, `ui-*`, Tailwind 유틸리티를 우선 사용한다.
- 각 메뉴별 최종 시각 검수는 로그인 후 실제 데이터가 있는 화면에서 계속 확인해야 한다.
- 화면별 업무 로직, Stored Procedure, Membership/Role Provider, hidden field 직렬화 포맷은 이번 UI 마이그레이션에서 변경하지 않는다.

### 7. 수양회 전환과 과거 수양회 안내

- `staff/retreat.aspx`에서 수양회 사용여부를 `사용(Y)`으로 저장하면 해당 수양회만 `Y`로 남고 나머지 수양회는 자동으로 `N` 처리된다.
- 이 단일 활성화 처리는 `SP_retreat_set_only_active`에서 수행한다.
- 상단 메뉴의 `수양회 전환` 버튼도 같은 SP를 호출하므로 수양회 관리 화면에 직접 들어가지 않아도 현재 사용 수양회를 바꿀 수 있다.
- 수양회 전환은 시스템 전체 기준을 바꾸므로 `admin`, `manager` 권한에서만 노출한다.
- 현재 사용 수양회가 가장 최근 생성된 수양회가 아니면 일반 화면 상단 중앙에 붉은 안내 문구를 표시한다.
  - 문구: `과거 수양회(수양회명) 내용으로 보는 중입니다.`
  - `시스템` 하위 메뉴와 `My정보수정` 하위 메뉴에서는 이 안내 문구를 표시하지 않는다.
  - 인쇄/no-frame 마스터 화면에는 공통 `page_header`가 없으므로 표시되지 않는다.

### 8. 엑셀 저장 xlsx 전환

- 기존 GridView HTML 기반 `.xls` 다운로드를 OpenXML 기반 `.xlsx` 생성 방식으로 전환했다.
- 공통 생성기는 `App_Code/XlsxExportHelper.cs`이며 외부 NuGet 패키지 없이 `System.IO.Packaging`으로 xlsx zip 패키지를 만든다.
- `Web.config`의 `compilation/assemblies`에 `WindowsBase` 참조를 추가했다.
- 적용된 export 페이지:
  - `staff/registatus_excel_export.aspx.cs`: 등록현황 `RegistListReport_yyyyMMdd-HHmmss.xlsx`
  - `staff/in_ex_excel_export.aspx.cs`: 수입현황 `IncomesReport_yyyyMMdd-HHmmss.xlsx`, 지출현황 `ExpensesReport_yyyyMMdd-HHmmss.xlsx`
- 기존 iframe 호출 방식과 query string은 유지하되, `custom.js`의 `excel_export`, `income_list_excel`, `expenses_list_excel` 호출 URL은 extensionless canonical URL로 맞췄다.

### 9. `.aspx` 생략 URL 전환

- 런타임 진입 URL은 `/member/login`, `/staff/income`, `/staff/in_ex_excel_export?ret=...`처럼 `.aspx`를 생략한 형태를 canonical로 사용한다.
- `Global.asax`는 애플리케이션 시작 시 `WebRoot` 아래의 `.aspx` 파일을 스캔해 extensionless route를 등록한다.
  - 예: `staff/income.aspx` -> `/staff/income`
  - `Default.aspx`는 별도 route를 만들지 않고 `/`를 canonical로 둔다.
- FTP 배포 후 앱 도메인이 재시작되지 않아 새 `.aspx` 파일의 route가 아직 등록되지 않은 경우를 대비해, `Application_BeginRequest`에서 extensionless 경로와 같은 이름의 `.aspx` 파일이 있으면 요청 시점에 해당 파일로 rewrite한다.
- `.aspx`로 직접 접근하면 canonical URL로 리다이렉트한다.
  - `GET`, `HEAD`: `Response.RedirectPermanent(..., false)`로 301 처리
  - 그 외 메서드: status `308`과 `RedirectLocation`으로 처리
  - `/default.aspx`와 `/default`는 `/`로 정규화한다.
- URL 표준화는 `App_Code/CodeHelper.cs`에 모았다.
  - `ToCanonicalPath(path)`: `.aspx` 제거, 소문자화, `/default*`를 `/`로 변환
  - `ToCanonicalUrl(url)`: 내부 URL과 현재 사이트의 절대 URL만 canonical 변환. 외부 절대 URL은 변경하지 않는다.
  - `GetCurrentCanonicalPath()`: 현재 요청을 브라우저 canonical 경로로 반환
  - `GetCurrentMenuPath()`: DB 메뉴 조회용 경로로 반환
- `menu_master.menu_path`와 `SP_menu_*`는 기존 `.aspx` 경로를 계속 기준으로 조회한다. 따라서 메뉴/권한/breadcrumb 조회에는 `GetCurrentMenuPath()`를 쓰고, DB에서 읽은 메뉴 링크를 화면에 출력할 때는 `ToCanonicalUrl()`을 통과시킨다.
- 신규 코드에서 내부 링크, `Response.Redirect`, `CodeHelper.Redirect`, `location.href`, `location.replace`, `window.open`, iframe `src`를 작성할 때는 `.aspx`를 붙이지 않는다.
- 기존 직접 링크 점검은 아래 패턴 검색으로 수행했다.
  - `href="/...aspx"`
  - `location.href = "/...aspx"`
  - `location.replace("/...aspx")`
  - `window.open("/...aspx?...")`
  - `Response.Redirect("/...aspx", ...)`
  - `CodeHelper.Redirect(..., "/...aspx...")`
  - iframe `Src = "...aspx?..."`
- 검증 결과:
  - 내부 이동 패턴의 `.aspx` 직접 링크 검색 결과 없음
  - `.NET Framework MSBuild`의 `ubfgj3.slnx` 빌드 통과, 경고 0 / 오류 0
  - `aspnet_compiler -v /localhost_5000 -p .\WebRoot -u -f .\PrecompiledWeb\review_check` 통과
  - `dotnet build`는 Web Site 프로젝트 특성상 계속 사용하지 않는다.

### 10. 모바일·인앱 브라우저용 프로그램 PDF 뷰어

- 공개 메인의 `프로그램 세부보기`는 브라우저 내장 PDF 플러그인에 의존하지 않고 `/retreat_program_viewer`의 사이트 전용 뷰어를 연다.
- 전용 뷰어는 Mozilla PDF.js 4.10.38 legacy 배포본을 `common/vendor/pdfjs-4.10.38`에 자체 호스팅하고 PDF 페이지를 HTML5 canvas로 렌더링한다. 외부 CDN이나 별도 PDF 앱 설치가 필요하지 않다.
- `/retreat_program`은 DB의 원본 파일을 반환하는 같은 출처 데이터 endpoint로 유지한다. `?download=1`이면 `Content-Disposition: attachment`로 파일 저장을 제공한다.
- 뷰어는 페이지 이동, 페이지 번호 입력, 확대·축소, 너비 맞춤, 파일 저장을 제공한다. 모바일에서는 전체 폭과 44px 이상의 터치 영역을 사용하고 문서 페이지를 세로로 탐색한다.
- 화면 근처의 페이지만 지연 렌더링하고 고해상도 화면의 canvas 픽셀 수를 제한해 모바일 메모리 사용량을 억제한다.
- PDF가 아닌 이미지 안내 파일도 같은 뷰어에서 바로 표시한다. PDF.js를 시작할 수 없는 오래된 브라우저에는 원본 열기와 파일 저장 fallback을 표시한다.
- PDF.js는 `isEvalSupported=false`로 실행하고 뷰어 응답에 자체 CSP를 적용한다. IIS에서 `.mjs`와 `.bcmap`을 제공할 수 있도록 `Web.config`에 MIME mapping을 등록한다.

## 실행 환경

필수 구성:

- Windows + IIS Express 또는 IIS
- .NET Framework 4.x 런타임/Developer Pack
- SQL Server 접근 가능 환경
- `WebRoot/appsettings.json`의 DB/SMTP 설정

로컬 실행 시 확인할 것:

1. Visual Studio에서 `C:\MyApps\ubfgj3.kr`를 웹 사이트로 연다.
2. IIS Express 설정이 필요하면 `.vs` 설정의 물리 경로가 `C:\MyApps\ubfgj3.kr\WebRoot`인지 확인한다.
3. `WebRoot/appsettings.json`의 `RetreatConnectionString`이 접근 가능한 DB를 가리키는지 확인한다.
4. 수입·지출 증빙 이미지는 `staff/income.aspx.cs`, `staff/expenses.aspx.cs`의 하드코딩된 경로를 사용한다.
   - 운영 도메인이 아니면 코드상 기본 분기 때문에 로컬에서도 운영 경로가 선택될 수 있다.
   - 로컬 테스트 전 `_attatch` 저장 경로와 쓰기 권한을 반드시 맞춘다.
5. `appsettings.json`에는 DB와 SMTP 비밀값이 포함되어 있으므로 공개 저장소에 올리거나 문서에 그대로 복사하지 않는다.
6. 로컬 IIS Express 테스트는 `http://localhost:5000`만 사용한다. 로컬 테스트용 HTTPS 바인딩은 사용하지 않는다.
7. HTTPS 리다이렉트 코드는 운영 도메인 `ubfgj3.kr`, `www.ubfgj3.kr`에서만 동작하므로 localhost 테스트는 HTTP로 유지된다.

Visual Studio 디버깅 버튼으로 로컬 테스트:

- `C:\MyApps\ubfgj3.kr\ubfgj3.slnx`를 연다.
- 시작 프로젝트는 `WebRoot`다. `ubfgj3.slnx`에서 `WebRoot`를 첫 프로젝트로 두어 기본 F5 대상이 되도록 구성했다.
- 디버깅 대상은 IIS Express다.
- F5 또는 디버깅 버튼 실행 시 `http://localhost:5000`으로 접속한다.
- Visual Studio가 이전 `.suo` 사용자 설정을 계속 사용해 다른 프로젝트를 시작하려 하면 솔루션 탐색기에서 `WebRoot`를 `시작 프로젝트로 설정`한 뒤 다시 실행한다.

## 설정 파일 구성

DB 연결 문자열과 SMTP 계정은 `WebRoot/Web.config`에서 제거하고 `WebRoot/appsettings.json`으로 분리했다.

`appsettings.json` 구조:

- `ConnectionStrings.RetreatConnectionString.ConnectionString`: SQL Server 연결 문자열
- `ConnectionStrings.RetreatConnectionString.ProviderName`: ADO.NET Provider 이름
- `Smtp.From`, `Host`, `Port`, `UserName`, `Password`, `EnableSsl`, `DefaultCredentials`: 메일 발송 설정

`Web.config`는 실제 비밀값을 직접 보관하지 않고 `appSettings`의 `ExternalSettingsFile`로 `appsettings.json` 파일명을 참조한다. 또한 `system.webServer/security/requestFiltering/hiddenSegments`에 `appsettings.json`을 등록해 브라우저에서 설정 파일을 직접 내려받지 못하도록 차단한다.

ASP.NET Membership/Role Provider는 `RetreatConnectionString` 이름을 계속 사용한다. 다만 Provider 타입은 `JsonSqlMembershipProvider`, `JsonSqlRoleProvider`로 감싸 두었고, 이 래퍼가 초기화될 때 `AppConfiguration`을 통해 `appsettings.json`의 연결 문자열을 `ConfigurationManager.ConnectionStrings`에 주입한다.

비밀번호 찾기 `PasswordRecovery` 컨트롤은 기본 SMTP 설정을 `Web.config`에서 찾기 때문에 `member/findpwd.aspx.cs`의 `OnSendingMail` 이벤트에서 기본 발송을 취소하고 `CodeHelper.SendMail`로 발송한다. 따라서 비밀번호 복구 메일도 `appsettings.json`의 SMTP 설정을 사용한다.

## 솔루션 구성

`ubfgj3.slnx`에는 Web Site 프로젝트 `WebRoot`와 DB 프로젝트 `DB/DB.sqlproj`가 포함된다.

- `WebRoot` 로컬 테스트 포트는 `5000`이다.
- IIS Express 바인딩은 `http://localhost:5000`만 사용한다.
- Visual Studio F5 디버깅 대상이 되도록 `WebRoot`를 솔루션 첫 프로젝트로 둔다.
- DB 프로젝트는 솔루션에는 표시되지만 솔루션 빌드 대상에서는 제외된다.
- DB 프로젝트는 Stored Procedure 소스 형상 관리를 위한 용도다.
- `DB/StoredProcedure/**/*.sql` 파일은 `None` 항목으로 관리하며, SQL 프로젝트 빌드 산출물을 만들기 위한 대상이 아니다.
- 개별 SP는 `DB/StoredProcedure/SP명.sql` 파일에 `CREATE OR ALTER PROCEDURE` 형태로 둔다.
- 운영 서버에 SP를 한 번에 반영할 때는 `DB/StoredProcedure/All_SP_LIST.sql`을 실행한다.

## 폴더 구조

| 경로 | 역할 |
| --- | --- |
| `Default.aspx(.cs)` | 공개 메인. 활성 수양회 안내, 장소/기간, 회비 구분, 프로그램 PDF 모달 표시 |
| `retreat_program_viewer.aspx(.cs)` | PDF.js 기반 프로그램 문서 뷰어. 모바일·인앱 브라우저 대응 |
| `retreat_program.aspx(.cs)` | 활성 수양회 안내 원본을 inline 또는 다운로드 응답으로 스트리밍 |
| `App_Code/` | 공통 C# 코드. DB 헬퍼, 사용자/역할 헬퍼, 메일/페이지 유틸 |
| `master/` | 공통 레이아웃 마스터 페이지. 일반 화면과 인쇄용 no-frame 마스터 |
| `usercontrol/` | 상단 메뉴, 좌측 메뉴/요약, breadcrumb, footer |
| `member/` | 로그인, 로그아웃, 회원가입, ID/PW 찾기, ID 중복 확인 |
| `info/` | 내 정보 수정, 본인확인 질문 변경, 비밀번호 변경 |
| `manage/` | 관리자용 요회 관리, 회원 관리/승인/잠금/비밀번호 초기화 |
| `group/` | 요회 담당자/실무자용 참석자 및 회비 입력 |
| `staff/` | 실무자용 수양회/회비/수입/지출/현황/엑셀/인쇄 |
| `common/css`, `common/js` | 로컬 Tailwind CSS, jQuery, jQuery UI, 공통 UI 스타일/스크립트 |
| `_attatch/` | 수입·지출 증빙 이미지 저장 위치. 실제 코드의 파일 저장 루트와 일치해야 함 |

## 공통 코드

`App_Code/AppConfiguration.cs`

- `WebRoot/appsettings.json`을 읽어 DB 연결 문자열과 SMTP 설정을 제공한다.
- `ExternalSettingsFile` 값이 있으면 해당 파일명을 사용하고, 없으면 기본값 `appsettings.json`을 사용한다.
- Membership/Role Provider가 기존 `RetreatConnectionString` 이름으로 동작할 수 있도록 런타임에 연결 문자열을 주입한다.

`App_Code/EfStoredProcedure.cs`

- Entity Framework 6의 `DbContext` 연결을 사용해 Stored Procedure를 실행하는 공통 모듈이다.
- `EfStoredProcedure.ExecuteDataSet`, `ExecuteNonQuery`, `ExecuteScalar`를 제공한다.
- 화면 코드는 인라인 SQL 문자열을 직접 조합하지 않고 이 헬퍼와 `SqlParameter`로 SP를 호출한다.
- EF6 DLL은 `WebRoot/Bin/EntityFramework.dll`, `WebRoot/Bin/EntityFramework.SqlServer.dll`에 배치한다.

`App_Code/JsonMembershipProviders.cs`

- `SqlMembershipProvider`, `SqlRoleProvider`를 감싼 래퍼 Provider다.
- Provider 초기화 전에 `AppConfiguration.ApplyToConfigurationManager()`를 호출해 `appsettings.json`의 DB 연결 문자열을 적용한다.

`App_Code/SqlHelper.cs`

- 과거 ADO.NET 기반 DB 실행 헬퍼다.
- 신규/수정 화면 코드는 `EfStoredProcedure`를 통해 Stored Procedure를 호출한다.
- ASP.NET Membership Provider나 기존 호환 코드가 필요할 때만 제한적으로 유지한다.

`App_Code/CodeHelper.cs`

- `Redirect(message, url)`: alert 후 이동
- `ShowMessageBox`: 클라이언트 alert 등록
- `GetUserIP`: 요청 IP 확인
- `RetreatCode`: 활성 수양회 `seq` 조회
- `GetGroupName`, `GetPagetitle`, `GetCashCode`, `GetFilePath`, `GetFileUrl`
- `SendMail`: `WebRoot/appsettings.json` SMTP 설정을 이용한 HTML 메일 발송

`App_Code/UserInfo.cs`

- 현재 로그인 ID, 역할, 역할 설명, 이메일, 이름, 소속 요회 코드를 반환한다.
- ASP.NET Membership 테이블과 자체 `member_master` 테이블을 함께 조회한다.
- 역할명은 `aspnet_Roles.LoweredRoleName` 기준으로 `admin`, `manager`, `user`를 사용한다.

`App_Code/XlsxExportHelper.cs`

- DataTable을 OpenXML 기반 `.xlsx` 파일로 만들어 `HttpResponse`에 내려보내는 공통 헬퍼다.
- `WriteDataTableToResponse(response, table, fileName, sheetName)`와 열 너비 자동 맞춤 여부를 받는 5번째 `bool` 인수 overload를 제공한다.
- 첫 행은 DataTable 컬럼명을 헤더로 쓰고, 숫자 자료형 컬럼은 xlsx 숫자 셀로 저장한다.
- 자동 맞춤을 사용하면 헤더와 전체 셀의 표시 길이를 계산해 OpenXML `cols/col` 너비를 기록한다. 한글은 영문보다 넓게 계산하고 Excel 최대 너비 255를 넘지 않게 한다.
- `System.IO.Packaging`을 사용하므로 `Web.config`에 `WindowsBase` assembly 참조가 필요하다.
- 현재 등록현황, 수입현황, 지출현황, 식사 선택 상세 엑셀 다운로드에서 사용한다.

`App_Code/ParameterExtender/`

- `CustomParameter`, `ParameterType`은 `SqlHelper`의 파라미터 바인딩 보조 클래스다.

## 인증과 권한

`Web.config` 설정:

- `authentication mode="Forms"`
- 로그인 페이지: `/member/login`
- Membership Provider: `RetreatSqlMembershipProvider`
- Role Provider: `RetreatSqlRoleProvider`
- `WindowsBase` assembly 참조가 등록되어 있어 OpenXML `.xlsx` 생성 시 `System.IO.Packaging`을 사용할 수 있다.
- 비밀번호 최소 길이 7자, 특수문자 1자 이상, 해시 저장
- 실제 DB 연결 문자열은 `appsettings.json`에서 읽어 런타임에 `RetreatConnectionString` 이름으로 주입한다.
- `Web.config`에는 DB 연결 문자열과 SMTP 비밀번호를 직접 넣지 않는다.

역할:

| 역할 | 의미 | 접근 범위 |
| --- | --- | --- |
| `anonymous` | 비로그인 | 공개 메뉴 |
| `user` | 요회담당자 | 자기 요회 구성원/회비 입력 중심 |
| `manager` | 실무자 | `user` 권한 + 실무 확인/수입·지출 관리 |
| `admin` | 시스템관리자 | 전체 메뉴 |

메뉴와 접근 제어:

- 메뉴는 `menu_master`에서 읽는다.
- `menu_auth='user'`면 `admin/manager/user` 접근 가능.
- `menu_auth='manager'`면 `admin/manager` 접근 가능.
- `admin`은 모든 권한 메뉴를 볼 수 있다.
- `usercontrol/top_nav.ascx.cs`의 `GetAuth()`가 현재 경로의 `menu_auth`를 조회하고 권한이 없으면 `/`로 보낸다.
- 새 페이지를 추가하면 코드만 만들지 말고 `menu_master`에도 경로와 권한을 등록해야 메뉴와 권한이 맞는다.

로그인/가입:

- `/member/login.aspx.cs`: `Membership.ValidateUser`로 인증한다.
- 로그인 실패 횟수는 `MembershipUser.Comment`에 저장한다.
- 실패 횟수가 `Membership.MaxInvalidPasswordAttempts` 이상이면 `IsApproved=false`로 잠근다.
- `/member/join.aspx.cs`: Membership 계정 생성, Role 추가, `member_master` 추가, `admin`에게 가입 알림 메일 발송.
- 가입 시 `Membership.CreateUser(..., isApproved:false, ...)`로 생성되므로 관리자 승인 전에는 로그인할 수 없다.

## 주요 업무 흐름

### 1. 수양회 기본 정보 공개

파일:

- `Default.aspx`
- `Default.aspx.cs`

동작:

- 활성 수양회 한 건을 `retreat_master`에서 조회한다.
- 장소, 기간, 소개, 회비 구분을 화면에 표시한다.
- `retreat_master.file_nm`, `file_data`가 있으면 프로그램 세부보기 버튼을 활성화한다.
- 버튼은 `/retreat_program_viewer`의 PDF.js 뷰어를 모달 iframe으로 표시하며, 같은 뷰어를 새 탭으로 열 수도 있다.
- PDF 모달은 데스크톱에서 jQuery UI `draggable`, `resizable`로 이동과 크기 조절을 지원한다.
- 회비 정보는 `retreatdues_master`와 `retreat_master.etc1`의 납부 계좌를 표시한다.

### 2. 수양회/회비/요회 마스터 준비

수양회 관리:

- 파일: `staff/retreat.aspx(.cs)`
- 테이블: `retreat_master`
- 저장 프로시저: `ubfgj3.dbo.SP_retreatinfo_sav`, `SP_retreat_set_only_active`
- 관리 항목: 수양회명, 장소, 시작/종료일, 소개, 납부계좌, 안내 첨부파일, 사용 여부
- 사용여부를 `사용(Y)`으로 저장하면 `SP_retreat_set_only_active`가 해당 수양회만 `Y`로 두고 기존 활성 수양회는 자동으로 `N` 처리한다.
- 상단 메뉴의 `수양회 전환` 모달에서도 같은 SP를 호출해 현재 사용 수양회를 바꾼다.
- 삭제 제한: 해당 수양회에 `group_members` 또는 `retreatdues_master` 데이터가 있으면 삭제 불가

회비 구분 관리:

- 파일: `staff/retreatdues.aspx(.cs)`
- 테이블: `retreatdues_master`
- 관리 항목: 수양회, 회비구분명, 금액, 비고
- 삭제 제한: 해당 회비 구분을 사용하는 `group_members`가 있으면 삭제 불가

요회 관리:

- 파일: `manage/groups.aspx(.cs)`
- 테이블: `groups`
- 관리 항목: 요회명, 요회목자, 사용여부(`etc1`)
- 현재 수양회에 요회가 없으면 가장 최근 이전 수양회의 요회 목록을 자동 복사한다.
- `groups.etc1='Y'`인 요회만 일반 선택 목록과 현황에 표시된다.

### 3. 요회별 구성원 및 회비 입력

파일:

- `group/usermanage.aspx`
- `group/usermanage.aspx.cs`
- `common/js/custom.js`

핵심 테이블:

- `group_members`
- `groups`
- `retreatdues_master`

권한별 동작:

- `user`: 자기 소속 요회만 선택 가능.
- `manager`, `admin`: 요회 선택 가능.
- `manager`, `admin`이 금액을 입력/수정하면 납부금액이 0이 아닌 경우 `manager_confirm='Y'`로 저장된다.
- `user`가 이미 실무확인된 항목의 금액, 이름, 회비구분을 바꾸면 `manager_confirm='N'`으로 되돌려 실무자가 재확인하도록 한다.

화면 입력 방식:

- 서버가 기존 구성원을 hidden field에 `†`, `‡` 구분 문자열로 내려준다.
- `custom.js`의 `set_table_usermanage()`가 HTML 테이블 행을 만든다.
- 저장 시 `save_members_table()`이 테이블 내용을 다시 hidden field `hdSaveMembers`에 직렬화한다.
- 서버의 `btnSave_Click()`이 문자열을 분해해 `group_members`를 insert/update/delete 한다.
- 저장된 seq 목록에 없는 기존 행은 삭제된다.
- 단, 일반 `user`는 실무 확인된 행을 삭제하지 못하도록 조건이 있다.

이전 수양회 구성원 이관:

- 현재 요회에 구성원이 없고, 이전 수양회의 같은 요회명이 존재하며, 현재 수양회 회비 구분이 있으면 이관 버튼을 표시한다.
- 이름, 회원구분은 복사하고 납부금액은 0으로 초기화한다.
- 회비구분은 이전/현재 `dues_nm`이 같으면 매핑한다.

참석 상태:

- `group_members.etc2`
- `N`: 미참석
- `P`: 부분참석
- `A`: 완전참석

회원구분:

- `group_members.usertype=1`: 목자
- `group_members.usertype=2`: 목동
- `group_members.usertype=3`: 양

납부방법:

- `group_members.howto_regist=1`: 계좌이체
- `group_members.howto_regist=2`: 현금납부

### 4. 실무자 등록 확인

파일:

- `staff/registatus.aspx`
- `staff/registatus.aspx.cs`
- `staff/registatus_excel_export.aspx(.cs)`

동작:

- 요회/등록여부로 `group_members` 목록을 필터링한다.
- 납부금액이 0보다 큰 항목만 실무확인 체크가 가능하다.
- 저장 시 체크 상태에 따라 `group_members.manager_confirm`을 `Y/N`으로 갱신한다.
- `etc1`은 최초 확인 또는 재확인 표시 용도로 사용된다.
- 엑셀 저장은 관리자/실무자만 가능하며 OpenXML 기반 `.xlsx` 파일로 내려보낸다.
- 등록현황 엑셀은 `SP_registatus_excel_get_list` 결과 DataTable을 `XlsxExportHelper`로 내려보낸다.
- 파일명은 `RegistListReport_yyyyMMdd-HHmmss.xlsx` 형식이다.

등록 상태 계산:

- `user_dues >= retreatdues_master.dues`: 완전등록
- `user_dues > 0` 그리고 기준 회비 미만: 부분등록
- `user_dues <= 0`: 미등록

수양회비 수입 집계:

- 수입 화면과 현황에서는 실무자가 확인한 `group_members.manager_confirm='Y'` 데이터만 수양회비로 집계한다.

### 5. 수입·지출 관리

파일:

- `staff/income.aspx(.cs)`
- `staff/expenses.aspx(.cs)`
- `staff/items.aspx(.cs)`
- `staff/in_ex_excel_export.aspx(.cs)`
- `staff/in_ex_detail_print.aspx(.cs)`
- `staff/in_ex_all_print.aspx(.cs)`

테이블:

- `cash_item_master`
- `payment_master`
- `group_members`

수입/지출 코드:

- `cash_item_master.cash_type=1`: 수입코드
- `cash_item_master.cash_type=2`: 지출코드
- 수입/지출 코드는 수양회별로 분리하지 않고 전체 공통 코드로 사용한다.
- `cash_item_master.retreat` 컬럼은 기존 스키마 호환용으로 남아 있으며 신규/수정 시 기본값 `1`을 저장한다. 목록/선택/삭제확인 로직은 수양회 조건으로 필터링하지 않는다.
- 수입 입력에서는 `item_nm='수양회비'` 항목을 제외한다. 수양회비는 `group_members` 확인 데이터에서 계산된다.

수입/지출 목록:

- `SP_income_get_list(retreat, type, excelYn)`를 사용한다.
- `type=1`: 수입
- `type=2`: 지출
- 수입 목록에는 수양회비 합산 행이 포함될 수 있고, 그 행은 `seq=9999999`로 취급되어 상세 수정이 막혀 있다.

증빙 이미지:

- 파일은 DB에 직접 저장하지 않고 파일 시스템에 저장한다.
- DB `payment_master`에는 `file_nm`, `file_type`, `file_url`, `file_path`만 저장한다.
- 저장 URL은 `/_attatch/{retreat}/{guid}.{ext}` 형식이다.
- 업로드 후 이미지는 1200px 기준으로 리사이즈된다.
- 가로 이미지면 90도 회전시키는 로직이 있다.
- 기존 파일 교체 또는 삭제 시 실제 파일도 삭제한다.

인쇄/엑셀:

- 상세 인쇄: `/staff/in_ex_detail_print?seq={payment_seq}&type=1|2`
- 전체 인쇄: `/staff/in_ex_all_print?ret={retreat_seq}&type=1|2`
- 엑셀: `/staff/in_ex_excel_export?ret={retreat_seq}&type=1|2`
- 수입/지출 엑셀은 `SP_income_get_list(retreat, type, 'Y')` 결과 DataTable을 `XlsxExportHelper`로 내려보낸다.
- `type=1`은 `IncomesReport_yyyyMMdd-HHmmss.xlsx`, `type=2`는 `ExpensesReport_yyyyMMdd-HHmmss.xlsx` 파일명으로 다운로드된다.
- 인쇄 화면은 `master_main_noframe.master`를 사용하고 로드 즉시 `window.print()`를 실행한다.

### 6. 종합 현황

파일:

- `staff/status.aspx`
- `staff/status.aspx.cs`

모드:

- `mode=1` 또는 생략: 등록현황
- `mode=2`: 수입·지출현황
- `mode=3`: 참석현황

등록현황:

- 전체와 요회별로 리더/양, 완전등록/부분등록/미등록 인원을 집계한다.
- 요회명 caption은 해당 요회의 `/group/usermanage`로 연결된다.

수입·지출현황:

- `SP_income_get_list_status(retreat, type)`를 사용한다.
- 수입과 지출을 각각 항목별 집계하고, `총 결산 = 총 수입 - 총 지출`을 표시한다.

참석현황:

- `group_members.etc2` 기준으로 완전참석/부분참석 인원을 집계한다.

## 주요 테이블 현황

소스와 `DB/StoredProcedure` 기준으로 확인되는 주요 테이블이다. 실제 스키마 변경 전에는 운영 DB에서 자료형, 제약조건, 인덱스를 별도로 확인해야 한다.

| 구분 | 테이블 | 주요 기능/현황 | 주요 컬럼 | 관련 SP |
| --- | --- | --- | --- | --- |
| 수양회 | `retreat_master` | 수양회 기본정보, 기간, 장소, 사용여부, 안내 첨부파일, 납부 계좌 관리 | `seq`, `retreat_name`, `retreat_place`, `retreat_desc`, `retreat_sdt`, `retreat_edt`, `retreat_yn`, `file_nm`, `file_type`, `file_size`, `file_data`, `etc1` | `SP_retreat_*`, `SP_staff_retreat_get_list`, `SP_manage_retreat_recent_sel` |
| 회비 | `retreatdues_master` | 수양회별 회비 구분과 금액 관리. 구성원 등록과 등록현황 계산의 기준 | `seq`, `retreat`, `dues_nm`, `dues`, `dues_desc`, audit 컬럼 | `SP_retreatdues_*`, `SP_staff_retreatdues_*`, `SP_retreat_dues_by_retreat_sel` |
| 요회 | `groups` | 수양회별 요회, 요회목자, 사용여부 관리. 현재 수양회에 목록이 없으면 이전 수양회 목록을 복사 | `seq`, `belong_nm`, `manager`, `retreat`, `etc1`, audit 컬럼 | `SP_group_*`, `SP_groups_*`, `SP_manage_group_*` |
| 구성원/등록 | `group_members` | 요회 구성원, 회원구분, 회비구분, 납부금액, 실무확인, 참석여부 관리 | `seq`, `user_nm`, `belong`, `retreat`, `usertype`, `duestype`, `user_dues`, `howto_regist`, `user_desc`, `manager_confirm`, `etc1`, `etc2`, audit 컬럼 | `SP_group_members_*`, `SP_group_member_save`, `SP_registatus_*`, `SP_status_*` |
| 사이트 회원 | `member_master` | Membership 계정과 별도로 관리하는 사용자 프로필. 로그인 ID, 이름, 소속 요회, 이메일 저장 | `login_id`, `kor_nm`, `belong`, `belong_nm`, `email`, audit 컬럼 | `SP_member_*`, `SP_manage_member_*`, `SP_userinfo_*` |
| 메뉴/권한 | `menu_master` | 상단/좌측 메뉴, breadcrumb, 페이지 접근권한 제어 | `seq`, `parent_seq`, `menu_nm`, `menu_path`, `menu_depth`, `menu_order`, `menu_auth` | `SP_menu_*` |
| 수입/지출 코드 | `cash_item_master` | 수양회와 무관한 전체 공통 수입/지출 코드 관리. `retreat` 컬럼은 기존 스키마 호환용 값 | `seq`, `retreat`, `cash_type`, `item_nm`, `item_desc`, audit 컬럼 | `SP_staff_cash_item_*` |
| 수입/지출 내역 | `payment_master` | 수입/지출 금액, 날짜, 항목, 비고, 증빙 이미지 파일 경로 관리 | `seq`, `retreat`, `cash_item_seq`, `payment_dt`, `payment_item`, `payment`, `payment_item_desc`, `file_nm`, `file_type`, `file_url`, `file_path`, audit 컬럼 | `SP_staff_payment_*`, `SP_payment_*`, `SP_income_summary_sel` |
| Membership 사용자 | `aspnet_Users` | ASP.NET Membership 사용자 ID와 로그인명 | `UserId`, `UserName`, `LoweredUserName` | `SP_userinfo_*`, `SP_member_*`, `SP_manage_member_*` |
| Membership 인증 | `aspnet_Membership` | 이메일, 승인/잠금, 비밀번호 질문, 실패 횟수 등 인증 상태 | `UserId`, `Email`, `LoweredEmail`, `IsApproved`, `PasswordQuestion`, `Comment`, 실패/잠금 관련 컬럼 | `SP_member_*`, `SP_manage_member_*`, `aspnet_Membership_SetPassword` |
| Membership 역할 | `aspnet_Roles` | `admin`, `manager`, `user` 역할과 설명 | `RoleId`, `RoleName`, `LoweredRoleName`, `Description` | `SP_userinfo_*`, `SP_member_detail_sel`, `SP_manage_member_*` |
| Membership 역할 매핑 | `aspnet_UsersInRoles` | 사용자와 역할 연결 | `UserId`, `RoleId` | `SP_userinfo_*`, `SP_member_detail_sel`, `SP_manage_member_*` |

관계 요약:

- `retreat_master.seq`가 `groups.retreat`, `retreatdues_master.retreat`, `group_members.retreat`, `payment_master.retreat`의 기준이다.
- `groups.seq`는 `group_members.belong`, `member_master.belong`과 연결된다.
- `retreatdues_master.seq`는 `group_members.duestype`과 연결되어 등록금액 기준을 제공한다.
- `cash_item_master.seq`는 `payment_master.cash_item_seq`와 연결되어 수입/지출 항목을 분류한다.
- `aspnet_Users.UserName`과 `member_master.login_id`가 사용자 프로필 연결 기준이다.

날짜 저장 관례:

- `retreat_sdt`, `retreat_edt`, `payment_dt`는 문자열 `yyyyMMdd` 형태로 저장하고 화면에서 `yyyy-MM-dd`로 변환한다.

감사 컬럼 관례:

- 대부분의 업무 테이블에 `ins_id`, `ins_ip`, `ins_dt`, `upt_id`, `upt_ip`, `upt_dt`가 있다.
- 값은 현재 로그인 ID와 `CodeHelper.GetUserIP`, `GETDATE()`로 채운다.

상태/구분 값:

- `retreat_master.retreat_yn='Y'`: 현재 사용 중인 수양회
- `groups.etc1='Y'`: 사용 중인 요회
- `group_members.usertype`: `1=목자`, `2=목동`, `3=양`
- `group_members.howto_regist`: `1=계좌이체`, `2=현금납부`
- `group_members.manager_confirm`: 실무자 회비 확인 여부 `Y/N`
- `group_members.etc1`: 최초 확인 또는 재확인 표시
- `group_members.etc2`: 참석상태. `A=완전참석`, `P=부분참석`, `N=미참석`
- `cash_item_master.cash_type`: `1=수입`, `2=지출`

## 기능별 DB/SP 맵

| 기능 | 주요 화면 | 핵심 테이블 | 주요 SP/의존성 | 비고 |
| --- | --- | --- | --- | --- |
| 공개 수양회 안내 | `Default.aspx`, `retreat_program_viewer.aspx`, `retreat_program.aspx` | `retreat_master`, `retreatdues_master` | `SP_retreat_active_info_sel`, `SP_retreat_dues_by_retreat_sel`, `SP_retreat_active_file_sel` | 활성 수양회와 회비, PDF.js 문서 뷰어, 안내 원본 응답 |
| 인증/권한 | `member/login.aspx`, `usercontrol/top_nav.ascx` | ASP.NET Membership 테이블, `menu_master`, `member_master` | `SP_menu_auth_by_path_sel`, `SP_userinfo_*`, `SP_member_master_by_login_sel` | 로그인 자체는 `Membership.ValidateUser` 사용 |
| 수양회 전환/과거 안내 | `usercontrol/top_nav.ascx`, `usercontrol/page_header.ascx` | `retreat_master`, `menu_master` | `SP_retreat_get_list`, `SP_retreat_set_only_active`, `SP_menu_breadcrumb_current_sel` | `admin/manager` 전환 가능, 과거 수양회 안내 배너 표시 |
| 회원가입/내 정보 | `member/join.aspx`, `info/modify01.aspx`, `info/modify02.aspx` | `member_master`, `aspnet_Membership`, `groups` | `SP_member_*`, `SP_group_retreat_list_sel` | 가입 계정은 관리자 승인 전까지 로그인 불가 |
| 회원 관리 | `manage/members.aspx` | `member_master`, ASP.NET Membership/Role 테이블 | `SP_manage_member_*`, `aspnet_Membership_SetPassword` | 승인/잠금, 역할, 비밀번호 초기화 |
| 요회 관리 | `manage/groups.aspx` | `groups`, `retreat_master` | `SP_manage_group_*`, `SP_manage_retreat_recent_sel` | 이전 수양회 요회 자동 복사 포함 |
| 구성원/회비 입력 | `group/usermanage.aspx` | `group_members`, `groups`, `retreatdues_master` | `SP_group_members_*`, `SP_group_member_save`, `SP_groups_get_active_by_retreat` | hidden field 직렬화 방식 유지 |
| 실무 확인 | `staff/registatus.aspx` | `group_members`, `groups`, `retreatdues_master` | `SP_registatus_get_list`, `SP_registatus_confirm_update`, `SP_registatus_excel_get_list` | 확인된 회비만 수입 집계에 반영 |
| 수양회/회비 마스터 | `staff/retreat.aspx`, `staff/retreatdues.aspx` | `retreat_master`, `retreatdues_master`, `group_members` | `SP_retreat_*`, `SP_staff_retreatdues_*`, `SP_retreatinfo_sav`, `SP_retreat_set_only_active` | 수양회 저장은 기존 운영 SP 의존성 유지, 활성 수양회는 한 건만 유지 |
| 수입/지출 코드 | `staff/items.aspx` | `cash_item_master`, `payment_master` | `SP_staff_cash_item_*` | 사용 중인 결제 내역이 있으면 코드 삭제 제한 |
| 수입/지출 내역 | `staff/income.aspx`, `staff/expenses.aspx` | `payment_master`, `cash_item_master`, `group_members` | `SP_staff_payment_*`, `SP_payment_*`, `SP_income_summary_sel`, `SP_income_get_list` | 증빙 파일은 `_attatch`에 저장 |
| 인쇄/엑셀 | `staff/*print.aspx`, `staff/*export.aspx` | `payment_master`, `group_members` | `SP_payment_print_detail_get`, `SP_income_get_list`, `SP_registatus_excel_get_list` | OpenXML 기반 `.xlsx` 다운로드 |
| 종합 현황 | `staff/status.aspx` | `group_members`, `groups`, `retreatdues_master`, `payment_master` | `SP_status_*`, `SP_income_get_list_status` | 등록/수입·지출/참석 현황 표시 |

## 저장 프로시저 현황

SP 소스는 `DB/StoredProcedure` 아래에 관리한다. 개별 SP 파일은 `CREATE OR ALTER PROCEDURE` 형식이며, 운영 서버 반영용 통합 스크립트는 `DB/StoredProcedure/All_SP_LIST.sql`이다.

현재 현황:

- 개별 SP 소스: 89개
- 통합 실행 스크립트: `All_SP_LIST.sql`
- SQL 프로젝트 항목: 각 `.sql` 파일을 `None Include`로 명시 등록
- 솔루션 빌드: DB 프로젝트는 빌드/배포 대상에서 제외
- 웹 코드 호출 방식: `EfStoredProcedure.ExecuteDataSet`, `ExecuteNonQuery`, `ExecuteScalar` + `SqlParameter`

소스화된 SP 영역:

| 영역 | 개수 | 대표 SP | 기능 |
| --- | ---: | --- | --- |
| 수양회/회비 | 22 | `SP_retreat_*`, `SP_retreat_set_only_active`, `SP_retreatdues_*`, `SP_staff_retreatdues_*` | 활성 수양회, 수양회 목록/상세, 단일 활성 수양회 전환, 삭제 가능 여부, 회비 구분 CRUD |
| 요회/구성원 | 19 | `SP_group_*`, `SP_groups_*`, `SP_group_members_*`, `SP_manage_group_*` | 요회 목록/상세/저장, 구성원 저장/삭제/이관 |
| 회원/사용자 정보 | 18 | `SP_member_*`, `SP_manage_member_*`, `SP_userinfo_*` | 회원가입 보조, 내 정보, 회원 관리, 사용자/역할 조회 |
| 메뉴/권한 | 7 | `SP_menu_*` | 상단 메뉴, 좌측 메뉴, breadcrumb, 페이지 권한 조회 |
| 수입/지출 | 16 | `SP_staff_cash_item_*`, `SP_staff_payment_*`, `SP_payment_*`, `SP_income_summary_sel` | 수입/지출 코드 CRUD, 결제 CRUD, 요약/인쇄 상세 |
| 실무확인/현황 | 7 | `SP_registatus_*`, `SP_regist_info_sel`, `SP_status_*` | 등록현황, 실무확인 저장, 참석/등록 통계 |

운영 DB 기존 정의에 계속 의존하는 SP:

| 이름 | 호출 위치 | 현재 용도 | 비고 |
| --- | --- | --- | --- |
| `ubfgj3.dbo.SP_retreatinfo_sav` | `staff/retreat.aspx.cs` | 수양회 생성/수정/삭제 및 안내 첨부파일 저장 | DB 프로젝트에 아직 소스화되지 않음 |
| `ubfgj3.dbo.SP_income_get_list` | `SP_staff_payment_get_list`, `staff/in_ex_all_print.aspx.cs`, `staff/in_ex_excel_export.aspx.cs` | 수입/지출 목록 및 합계. 수양회비 합산 포함 가능 | 기존 운영 SP를 호출하는 래퍼가 있음 |
| `ubfgj3.dbo.SP_income_get_list_status` | `staff/status.aspx.cs` | 수입/지출 항목별 현황 집계 | DB 프로젝트에 아직 소스화되지 않음 |
| `aspnet_Membership_SetPassword` | `manage/members.aspx.cs` | 관리자 비밀번호 초기화 | ASP.NET Membership 내장 SP |

새 SP 추가/수정 규칙:

1. 개별 파일은 `DB/StoredProcedure/SP명.sql`로 만든다.
2. 본문은 `CREATE OR ALTER PROCEDURE`로 작성한다.
3. SQL 문자열 연결 대신 파라미터를 명시한다.
4. `All_SP_LIST.sql`을 개별 파일 기준으로 다시 생성한다.
5. `DB.sqlproj`에 새 파일을 `<None Include="StoredProcedure\SP명.sql" />`로 등록한다.
6. 모든 SQL 파일은 UTF-8 with BOM으로 저장한다.

## 식사수량 사전조사 (2026-07-17 구현)

### 사용자 흐름과 URL

- Home의 `수양회 식사여부 사전조사` 버튼은 비로그인 공개 화면 `/meal-precheck`로 이동한다.
- 공개 화면은 로그인하지 않은 경우 별도 공용 암호 인증 후 활성 수양회와 요회를 선택하고 구성원별 식사를 저장한다.
- 로그인 세션의 역할이 `user`(요회목자), `manager`, `admin`이면 공용 암호 없이 바로 접근한다. 요회목자는 `UserInfo.LoginUserBelongCode`의 소속 요회로 드롭다운과 서버 조회·저장 대상이 모두 고정되고, 실무자와 관리자는 전체 요회를 선택할 수 있다.
- 조사 명단에 사람이 없으면 `구성원` 열에 `전체 대상` 한 행을 표시하고 날짜·식사별 숫자 입력칸에 실제 식사 인원을 직접 입력한다. 상황에 따라 표 아래의 `신규인원 추가` 버튼으로 성명, 목자/목동/양, 학사/학생을 등록할 수도 있다. 활성 수양회의 `학사` 또는 `학생` 회비구분을 서버에서 찾아 기존 `SP_group_member_save`로 `group_members`에 추가하므로 `/group/usermanage`에도 즉시 나타난다.
- `manager`, `admin`은 `/staff/mealstatus`에서 요회별 집계·상세와 날짜별 식사 제공 사전설정을 관리한다.
- 현황 탭의 엑셀 다운로드는 `/staff/mealstatus_excel_export`에서 활성 수양회의 전체 요회를 조회한다. 일반 요회는 구성원 한 명을 한 행으로 두고 선택 `1`, 미선택 `0`을 출력한다. 명단이 없는 요회는 `전체 대상` 한 행에 날짜·식사별 실제 직접입력 수량을 출력한다.
- DB 메뉴 경로는 기존 메뉴 조회 규칙에 맞춰 `/staff/mealstatus.aspx`, 브라우저 URL은 extensionless로 유지한다.

### 화면과 업무 규칙

`/staff/mealstatus`:

- `manager`, `admin`만 접근할 수 있고 상단 수양회 드롭다운은 `SP_retreat_active_get`의 현재 사용 수양회로 고정한다.
- 첫 번째 `식사수량 현황` 탭은 전체와 요회별 카드로 구성한다. 식사를 하나 이상 선택한 구성원 수는 사람 기준으로 `명`, 날짜·식사별 합계는 `인분`으로 표시한다. `인분` 단위 글자 크기는 숫자의 50%다.
- 요회 제출 상태는 이후에도 수정할 수 있으므로 `제출완료`가 아니라 `제출`로 표시한다. 명단 또는 식사 설정 revision이 달라지면 `재확인 필요`, 저장 이력이 없으면 `미제출`이다.
- 요회명을 누르면 구성원별 선택·미선택 상태를 모달에서 확인한다. 명단 없는 요회는 `전체 대상` 행에서 식사별 직접입력 수량을 확인한다. 모바일 상세는 가로 표 대신 구성원별 카드와 날짜별 행을 사용하고 아침·점심·저녁 상태를 세로로 쌓아 좌우 스크롤 없이 표시한다. 상세 모달의 `식사인원 수정`은 `/meal-precheck?group={요회코드}`로 이동해 해당 요회를 바로 선택하고 수정할 수 있게 한다.
- 두 번째 `사전설정` 탭은 수양회 날짜를 열, 아침·점심·저녁을 행으로 출력한다. 저장된 설정이 없으면 첫날 저녁, 중간 날짜 전체 식사, 마지막 날 아침·점심을 기본 제공하며 하루짜리 수양회는 세 끼를 기본 제공한다.
- 설정 변경으로 현재 활성 상태의 개인 선택 또는 직접입력 수량과 충돌하면 일반 저장을 막고 경고한다. 사용자가 강제 저장을 선택한 경우 새 설정에서 제공하지 않는 식사의 활성 데이터를 정리한다. 구성원이 있어 휴면 상태인 직접입력 수량은 설정 충돌 집계와 정리 대상에서 제외해 보존하며, 현재 미제공 식사는 화면·통계에서 사용하지 않는다.

`/meal-precheck`:

- 수양회는 현재 사용 수양회로 고정하고 요회 변경 시 `/group/usermanage`와 같은 `group_members` 명단을 다시 바인딩한다. 요회목자는 로그인 소속 요회로 자동 선택·고정한다.
- 열에는 제공 대상으로 설정된 날짜와 식사만 표시한다. 각 구성원 이름 옆 `전체선택` 버튼은 그 사람의 모든 제공 식사를 선택하고 다시 누르면 전체 해제하며, 현재 상태에 따라 문구도 `전체선택`/`전체해제`로 바뀐다.
- 현재 명단이 0명이면 구성원별 체크박스 대신 `전체 대상` 행을 표시하고, 제공되는 날짜·아침/점심/저녁별로 0~9,999 범위의 실제 인원을 입력한다. 숫자 키패드를 유도하며 모든 입력칸은 44px 이상의 터치 영역을 확보한다.
- 직접입력 수량은 이후 구성원이 추가되어 개인별 체크 방식으로 전환되어도 삭제하지 않고 휴면 데이터로 보존한다. 현재 구성원이 1명 이상이면 직접입력 수량은 공개 화면·현황·통계·엑셀에서 제외하고 개인 선택만 사용한다. 구성원이 다시 0명이 되면 보존된 직접입력 수량을 다시 화면에 표시하고 집계·엑셀에도 재반영한다.
- `식사여부 저장`은 요회별 insert/update 방식으로 동작하고 성공 후 같은 요회로 돌아와 `저장되었습니다.` alert를 한 번 표시한다. alert와 중복되는 상단 성공 메시지는 표시하지 않는다.
- `신규인원 추가` 버튼은 구성원 목록 아래에 둔다. 모달에서 성명, 목자/목동/양, 학사/학생을 선택하면 `SP_group_member_save`로 구성원을 즉시 저장하고 `/group/usermanage`에도 함께 반영한다. 성공 후 별도의 상단 안내 메시지는 표시하지 않는다.
- 신규 구성원의 `@USER_DUES`는 `SqlDbType.Int` 값 `0`으로 명시하고, 회비 확인·관리자 확인·참석 여부는 미확인 기본값으로 저장한다. 추가 후 같은 요회로 리다이렉트하고 새 구성원 행을 강조한 뒤 화면 중앙으로 스크롤한다.
- 모바일 우선 화면으로 구성원 표를 카드 형태로 전환하고 체크 영역, 버튼, 모달의 터치 크기를 확보한다.
- 공개 조사와 실무자 화면에서 처리 오류, 입력 검증 오류, 암호 오류, 잠금 안내는 상단 배너나 브라우저 alert 대신 공통 `alertdialog` 모달로 표시한다. 오류 모달은 ESC·배경·확인 버튼으로 닫을 수 있고 포커스 trap과 호출 요소 복귀를 지원한다.

### 접근 권한과 공용 암호

| 접근 상태 | 처리 |
| --- | --- |
| 비로그인 | `appsettings.json`에 저장된 PBKDF2 설정으로 공용 암호를 검증한다. 평문 암호는 저장하지 않는다. |
| `user` 로그인 | 공용 암호를 생략하고 로그인 사용자의 소속 요회만 조회·저장한다. |
| `manager`, `admin` 로그인 | 공용 암호를 생략하고 모든 활성 요회를 조회·저장한다. |
| 그 외 로그인 역할 | 비로그인과 같은 공용 암호 절차를 적용한다. |

- 비로그인 암호는 브라우저 토큰 scope와 IP scope를 각각 관리한다. 어느 한쪽이라도 5회 연속 실패하면 10분간 재시도를 차단한다.
- 인증 성공 시 만료일 없는 브라우저 세션 쿠키를 사용한다. 브라우저 종료 전까지 유지하되 인증 시점부터 최대 2시간을 넘지 않는다.
- 로그인 세션으로 암호를 우회해도 저장·신규인원 추가 요청에는 CSRF 검증을 적용한다.

### 웹 파일과 보안

- 진입·화면: `Default.aspx`, `meal-precheck.aspx`, `staff/mealstatus.aspx`, `staff/mealstatus_excel_export.aspx`
- 공통 코드: `App_Code/MealPrecheckSecurity.cs`, `App_Code/MealPrecheckHelper.cs`, `App_Code/XlsxExportHelper.cs`
- 전용 자원: `common/css/meal-precheck.css`, `common/js/meal-precheck.js`
- 공개 암호는 `appsettings.json`의 `MealPrecheck`에 PBKDF2 hash/salt로 저장하며 평문을 저장하지 않는다.
- 로그인 우회 접근도 별도 CSRF 토큰을 발급·검증한다. 로그인 역할과 요회목자 소속은 매 요청마다 서버의 Membership/Role 및 회원 소속 정보로 다시 판별한다.
- 브라우저 토큰과 IP는 HMAC-SHA256 해시만 DB에 보관한다. 두 scope 중 하나라도 5회 연속 실패하면 10분간 잠긴다.
- 인증은 브라우저 세션 쿠키를 사용하고 인증 시점부터 최대 2시간만 허용한다. 공개 페이지는 `no-store`, `noindex`, ViewState 사용자 키, 별도 CSRF 토큰을 적용한다.
- 공개 저장은 현재 활성 수양회, 활성 요회, 현재 명단, 제공 중인 식사만 서버에서 다시 조회해 허용한다. 명단이 있으면 개인 선택(`P`), 명단이 없으면 직접 수량(`M`) payload만 허용한다. 두 방식의 데이터는 DB에 함께 보존될 수 있지만 화면 표시와 집계에 사용하는 활성 방식은 항상 현재 구성원 수로 결정한다. `meal_survey_submission.entry_mode`는 마지막 저장 방식을 기록할 뿐 활성 집계 방식을 결정하지 않는다. 클라이언트 값만 신뢰하지 않는다.
- 신규인원 추가도 인증 세션과 CSRF를 확인하고, 요회목자는 서버에서 로그인 소속 요회로 강제한다. 신규 인원은 납부액 0원, 미확인, 미참석 기본값으로 추가되며 성명과 선택 코드는 서버에서 허용 목록 검증한다.
- 설정과 요회 제출은 revision 기반 낙관적 동시성을 사용한다. 구성원 또는 식사 설정이 바뀐 제출은 `재확인 필요`로 표시한다.

`appsettings.json.local`의 `MealPrecheck` 값은 구조 예시다. 운영에서는 hash, salt, HMAC key를 각각 안전한 난수 기반 값으로 교체해야 한다.

### DB 객체

| 객체 | 역할 |
| --- | --- |
| `meal_service_config` | 수양회 날짜·식사별 제공 여부와 설정 revision |
| `meal_survey_submission` | 수양회·요회별 제출 header, 개인/직접입력 방식, 명단 hash, revision |
| `meal_survey_selection` | 구성원별 선택한 식사 detail |
| `meal_survey_manual_count` | 구성원 0명 요회의 날짜·식사별 실제 직접입력 수량 |
| `meal_access_guard` | 브라우저/IP scope별 실패 횟수와 잠금 시각 |

관련 SP는 `DB/StoredProcedure/SP_meal_*.sql` 10개이며 `DB.sqlproj`와 `All_SP_LIST.sql`에 포함한다. 구성원·요회 삭제와 수양회 삭제 제한은 기존 삭제 SP 4개에서 식사 조사 데이터까지 함께 처리한다.

| 구분 | Stored Procedure |
| --- | --- |
| 접근 제한 | `SP_meal_access_guard_get`, `SP_meal_access_failure_record`, `SP_meal_access_success_try` |
| 제공 설정 | `SP_meal_service_effective_get`, `SP_meal_service_save` |
| 공개 조사 | `SP_meal_survey_groups_get`, `SP_meal_survey_members_get`, `SP_meal_survey_save` |
| 실무자 현황 | `SP_meal_summary_get`, `SP_meal_group_detail_get` |

기존 삭제 연계 SP는 `SP_group_members_delete_by_group`, `SP_group_members_delete_missing`, `SP_manage_group_del`, `SP_retreat_delete_dependency_check`이며 식사 조사 header/detail 의존성을 함께 처리한다.

실제 DB 반영은 `WebRoot/appsettings.json` 연결정보를 읽어 `sqlcmd`로 수행한다. 현재 로컬 `sqlcmd 15.0`에서는 `-N`, `-C`를 모두 생략해 암호화를 선택적으로 두고 서버 인증서를 강제로 신뢰하지 않는다. `-I -b -V 11 -f 65001`을 사용하고 암호는 `SQLCMDPASSWORD` 환경변수로만 전달한다.

운영 정책상 전체 DB 백업은 수행하지 않는다. 기존 업무 테이블의 데이터를 변경해야 할 때만 사용자와 대상·백업명·보존기간을 확인한 뒤 같은 DB에 `SELECT * INTO [테이블_백업] FROM [테이블]` 형태의 테이블 단위 스냅샷을 만든다. 신규 테이블 생성처럼 기존 데이터가 바뀌지 않는 작업에는 불필요한 백업 테이블을 만들지 않는다.

### 엑셀 다운로드

- 현황 탭의 `엑셀 다운로드`는 `/staff/mealstatus_excel_export` GET 요청이며 `manager`, `admin`만 실행할 수 있다.
- 활성 수양회의 전체 활성 요회를 조회하고 일반 요회는 구성원 한 명을 한 행으로 출력한다. 구성원이 없는 요회는 `전체 대상` 한 행으로 남긴다.
- 고정 열은 `요회`, `제출상태`, `성명`, `회원구분`이고, 이후 열은 사전설정에서 제공되는 날짜·식사만 사용한다. `마지막저장`과 미제공 식사 열은 출력하지 않는다.
- 일반 요회는 선택한 식사 `1`, 선택하지 않은 식사 `0`을 출력한다. 명단 없는 요회는 각 식사의 실제 직접입력 수량을 출력하며 마지막 `선택합계`에는 해당 수량의 합을 기록한다.
- 첫 번째 헤더 행은 틀 고정해 아래 자료를 스크롤해도 열 제목이 계속 보이게 한다.
- `XlsxExportHelper`의 자동 너비 overload를 사용해 한글 헤더와 셀 내용이 잘리지 않도록 열 너비를 기록한다.
- 화면의 다운로드 링크는 JavaScript `fetch`와 동일 출처 로그인 쿠키로 export endpoint를 호출한다. 성공 응답은 Blob으로 저장하고 실패 응답은 JSON의 안전한 사용자 메시지를 읽어 현재 페이지의 공통 오류 모달에 표시하므로 오류 HTML 페이지로 이동하지 않는다.
- export 서버 예외 원문은 `Trace.Warn`에 기록하고 브라우저에는 일반화한 메시지만 보낸다. 권한이 없는 비동기 다운로드 요청은 HTTP 403 JSON으로 응답한다.

### 운영 배포 주의사항

- `WebRoot/appsettings.json`은 DB·SMTP·식사 조사 비밀값이 있어 Git과 일반 FTP 배포에서 제외한다. 신규 웹 파일만 FTP 배포하면 운영의 기존 설정 파일에는 `MealPrecheck` 블록이 자동으로 추가되지 않는다.
- 운영 반영 시 운영 `appsettings.json`을 별도 보관한 뒤 로컬 실제 설정 파일의 `MealPrecheck` 블록만 병합한다. 구조 예시인 `appsettings.json.local`을 운영에 올리거나 운영 DB/SMTP 값이 있는 파일 전체를 덮어쓰지 않는다.
- `MealPrecheck`가 없거나 hash/salt/HMAC/제한값 검증에 실패하면 `/meal-precheck` 첫 화면에 `식사 조사 설정을 확인할 수 없습니다. 관리자에게 문의하세요.`가 표시된다. 이 오류는 DB 조회 전 보안 초기화 단계에서 발생한다.
- `AppConfiguration`은 설정을 정적 캐시하므로 운영 `appsettings.json`을 수정한 뒤 앱 풀을 재활용한다. 앱 풀 제어가 불가능한 FTP 환경에서는 `Web.config`를 다시 배포해 AppDomain을 재시작할 수 있다.
- Home 버튼 공통 CSS는 `master/master_main.master`에서 `/common/css/custom.css?v=tailwind-52`로 로드한다. CSS 변경 후에는 query version을 올려 브라우저 캐시를 무효화한다.
- `수양회 식사여부 사전조사` 버튼은 `site-home-button-secondary`의 반투명 배경과 `backdrop-filter`를 사용하므로 같은 CSS라도 배경 이미지 위치, 화면 너비, 브라우저 렌더링에 따라 색이 다르게 보일 수 있다.

### 식사 조사 검증

- ASP.NET Web Site 전체는 `.NET Framework 4.8 aspnet_compiler.exe -v / -p .\WebRoot`로 사전 컴파일한다.
- DB migration 후 `DB/Migration/20260717_meal_precheck_verify.sql`을 재실행한다.
- 공개 화면은 첫 익명 GET에서 ASP.NET 세션 쿠키가 발급되는지, 암호 POST 후 요회·구성원 표와 CSRF 값이 출력되는지 확인한다.
- `user`, `manager`, `admin` 로그인 세션에서는 암호 화면이 생략되는지 확인한다. `user`는 소속 요회가 선택·비활성화되고 다른 요회 값을 변조해도 서버가 소속 요회만 사용하는지 확인한다.
- 신규인원 모달의 필수값·허용값 검증, 학사/학생 회비구분 매핑, 추가 직후 식사 명단과 `/group/usermanage` 양쪽 노출, 명단 변경에 따른 `재확인 필요` 상태를 확인한다.
- 식사여부 저장 성공 후 `저장되었습니다.` alert가 한 번 표시되는지, 신규인원 추가 후 같은 요회와 신규 행의 스크롤 위치가 유지되는지 확인한다.
- 명단 0명 요회에서 `전체 대상`과 날짜·식사별 숫자 입력칸이 표시되는지, 저장 후 같은 수량이 다시 표시되는지 확인한다. 명단이 추가되면 기존 직접입력 제출이 `재확인 필요`가 되고 개인별 체크 방식으로 전환되는지 확인한다.
- 직접 수량 저장 → 구성원 추가 → 개인별 식사 저장 → 구성원 전원 삭제 순서로 검증한다. 구성원이 있는 동안 직접 수량이 화면·현황·통계·엑셀에서 제외되고 DB에는 남아 있는지, 전원 삭제 후 기존 직접 수량이 다시 표시·집계되는지 확인한다.
- 구성원별 `전체선택`을 두 번 눌러 해당 사람의 제공 식사가 전체 선택된 뒤 전체 해제되는지 확인한다.
- `/staff/mealstatus`에서 제출한 요회가 `제출`로 표시되는지, 선택 구성원 수는 `명`, 식사별 수량은 작은 `인분` 단위로 표시되는지 확인한다.
- 식사 상세 엑셀에 전체 요회가 포함되는지, 미제공 식사와 `마지막저장` 열이 제외되는지 확인한다. 일반 요회는 `1/0`, 명단 없는 요회의 `전체 대상` 행은 실제 수량으로 출력되는지 확인한다.
- 암호 오류, 접근 잠금, 조회·저장 오류, 신규인원 입력 오류가 공통 오류 모달로 표시되고 닫은 뒤 호출 요소로 포커스가 돌아오는지 확인한다.
- 엑셀 endpoint에서 403 또는 500 오류가 발생했을 때 현재 현황 화면을 벗어나지 않고 오류 모달이 열리는지 확인한다.
- 모바일 320px·390px 폭에서는 공개 표가 구성원별 카드로 전환되고 44px 이상의 체크·숫자 입력 영역과 하단 저장 버튼이 유지되며 가로 넘침이 없는지 확인한다.

## 페이지별 유지보수 맵

| 기능 | 파일 | 확인할 DB/의존성 |
| --- | --- | --- |
| 메인 수양회 안내 | `Default.aspx.cs`, `retreat_program_viewer.aspx`, `retreat_program.aspx.cs` | `retreat_master`, `retreatdues_master`, `SP_retreat_*`, `SP_retreat_dues_by_retreat_sel`, PDF.js |
| 로그인/잠금 | `member/login.aspx.cs` | ASP.NET Membership |
| 회원가입 | `member/join.aspx.cs` | Membership, Roles, `member_master`, `SP_member_*`, SMTP |
| 아이디 찾기 | `member/findid.aspx.cs` | `member_master`, `SP_member_find_id_sel` |
| 비밀번호 찾기 | `member/findpwd.aspx` | `PasswordRecovery`, SMTP, Membership |
| 내 정보 수정 | `info/modify01.aspx.cs` | `member_master`, `aspnet_Membership`, `SP_member_detail_sel`, `SP_member_profile_upd` |
| 본인확인 질문 변경 | `info/modify02.aspx.cs` | Membership, `SP_member_password_question_sel` |
| 비밀번호 변경 | `info/modify03.aspx` | `ChangePassword` 컨트롤 |
| 회원 관리 | `manage/members.aspx.cs` | Membership, Roles, `member_master`, `SP_manage_member_*`, SMTP |
| 요회 관리 | `manage/groups.aspx.cs` | `groups`, `retreat_master`, `SP_manage_group_*` |
| 구성원/회비 입력 | `group/usermanage.aspx.cs`, `custom.js` | `group_members`, `groups`, `retreatdues_master`, `SP_group_members_*` |
| 수양회 관리/전환 | `staff/retreat.aspx.cs`, `usercontrol/top_nav.ascx.cs`, `usercontrol/page_header.ascx.cs` | `retreat_master`, `menu_master`, `SP_retreat_*`, `SP_retreatinfo_sav`, `SP_retreat_set_only_active` |
| 회비 구분 | `staff/retreatdues.aspx.cs` | `retreatdues_master`, `group_members`, `SP_staff_retreatdues_*` |
| 수입/지출 코드 | `staff/items.aspx.cs` | `cash_item_master`, `payment_master`, `SP_staff_cash_item_*` |
| 수입 관리 | `staff/income.aspx.cs` | `payment_master`, `cash_item_master`, `SP_staff_payment_*`, `SP_income_get_list`, `_attatch` |
| 지출 관리 | `staff/expenses.aspx.cs` | `payment_master`, `cash_item_master`, `SP_staff_payment_*`, `SP_income_get_list`, `_attatch` |
| 실무확인 | `staff/registatus.aspx.cs` | `group_members`, `groups`, `retreatdues_master`, `SP_registatus_*` |
| 종합현황 | `staff/status.aspx.cs` | `group_members`, `SP_status_*`, `SP_income_get_list_status` |
| 식사수량 사전조사 | `meal-precheck.aspx.cs`, `staff/mealstatus.aspx.cs`, `staff/mealstatus_excel_export.aspx.cs` | `meal_*`, `SP_meal_*`, `group_members`, `groups`, `retreat_master`, `XlsxExportHelper` |
| 엑셀/인쇄 | `staff/*export.aspx.cs`, `staff/*print.aspx.cs` | OpenXML `.xlsx` export, no-frame master |

## 새 기능 추가 절차

1. 페이지 파일을 추가한다.
   - 일반 화면: `MasterPageFile="~/master/master_main.master"`
   - 인쇄/팝업 화면: `~/master/master_main_noframe.master`
2. 공통 좌측 메뉴가 필요하면 `usercontrol/left_menu.ascx`를 등록한다.
3. 페이지 제목/breadcrumb를 쓰려면 `menu_master.menu_path`에 기존 `.aspx` 기준 경로를 등록한다.
4. 화면에 출력하는 링크와 리다이렉트 대상은 extensionless URL을 사용한다.
5. `menu_master.menu_auth`를 `anonymous`, `user`, `manager`, `admin` 중 하나로 설정한다.
6. DB 접근은 `EfStoredProcedure`와 `SqlParameter`로 Stored Procedure를 호출한다.
7. 인라인 SQL 문자열을 새로 추가하지 않는다.
8. 신규 업무 테이블에는 가능하면 기존 감사 컬럼 패턴을 따른다.
9. 클라이언트 검증이 필요한 경우 `common/js/custom.js`에 함수가 추가되는지 확인한다.
10. 수입/지출, 실무확인, 현황에 영향을 주는 변경은 관련 프로시저까지 같이 확인한다.
11. 모든 페이지는 모바일 우선으로 설계하고 최소 320px·390px 폭에서 가로 넘침, 44px 터치 영역, 입력 키패드, 모달·고정 버튼 동작을 확인한다.

## 운영/배포 체크리스트

- `appsettings.json`의 DB 연결 문자열과 SMTP 계정을 환경별로 분리한다.
- 운영 비밀값을 소스 저장소나 README에 그대로 기록하지 않는다.
- 모든 소스, 설정, 문서 파일은 UTF-8 with BOM으로 저장한다. Visual Studio에서 저장할 때 `UTF-8 signature` 또는 `UTF-8 with BOM` 인코딩인지 확인한다.
- 앱 풀은 .NET CLR 4, Integrated 모드로 설정한다.
- OpenXML `.xlsx` 생성에 `WindowsBase` assembly 참조가 필요하므로 운영 서버에 .NET Framework 4.x 런타임/Developer Pack 구성이 맞는지 확인한다.
- 운영 도메인 `ubfgj3.kr`, `www.ubfgj3.kr`는 HTTP 접근 시 HTTPS로 리다이렉트된다.
- `_attatch` 저장 루트와 `temp` 폴더에 앱 풀 계정 쓰기/삭제 권한이 필요하다.
- 운영 정책상 전체 DB 백업은 수행하지 않는다. 기존 테이블 데이터 변경이 필요한 경우에만 승인된 이름으로 `SELECT * INTO [테이블_백업] FROM [테이블]` 테이블 단위 백업을 사용한다.
- 변경하는 저장 프로시저 정의는 반영 전 텍스트로 보관하고 저장소의 개별 SP 파일과 비교한다.
- 수양회 전환 기능 배포 전 `SP_retreat_set_only_active`가 운영 DB에 반영되어 있는지 확인한다.
- 엑셀 출력은 OpenXML 기반 `.xlsx` 파일로 생성된다.
- 엑셀 export 변경은 DB 변경 없이 웹 코드와 `Web.config` 반영만 필요하다.

## 유지보수 주의점

- 현재 화면 코드의 DB 접근은 Stored Procedure와 `SqlParameter` 기반 호출로 정리되어 있다. 신규/수정 코드는 인라인 SQL 문자열을 추가하지 말고 `EfStoredProcedure`와 파라미터 바인딩을 사용한다.
- `new SqlParameter("@NAME", 0)`은 `0`이 값이 아니라 `SqlDbType` 생성자 인수로 해석될 수 있다. 숫자 0은 `new SqlParameter("@NAME", SqlDbType.Int) { Value = 0 }`처럼 타입과 값을 명시한다.
- 신규 엑셀 다운로드는 GridView HTML을 `.xls`로 렌더링하지 말고 `XlsxExportHelper.WriteDataTableToResponse()`를 사용한다.
- 현재 사용 수양회는 시스템 전체 기준이다. `staff/retreat.aspx` 또는 상단 `수양회 전환` 모달에서 수양회를 `사용(Y)`으로 바꾸면 다른 수양회는 자동으로 `N` 처리된다.
- 과거 수양회가 활성화된 상태에서는 일반 화면 상단에 `과거 수양회(수양회명) 내용으로 보는 중입니다.` 안내가 표시된다. 단, `시스템`, `My정보수정` 하위 메뉴와 no-frame 인쇄 화면에는 표시하지 않는다.
- `Web.config`에서 `validateRequest="false"`와 `requestValidationMode="2.0"`을 사용한다. HTML/스크립트 입력 방어는 각 페이지에서 별도로 해야 한다.
- 파일 저장 경로가 `staff/income.aspx.cs`, `staff/expenses.aspx.cs`에 하드코딩되어 있다. 배포 경로나 도메인이 바뀌면 증빙 업로드가 실패할 수 있다.
- 수입/지출 코드 관리(`staff/items.aspx.cs`)는 전체 공통 코드 기준이다. `cash_item_master.retreat` 값은 스키마 호환용이므로 수양회별 코드 분리 조건으로 사용하지 않는다.
- `group/usermanage.aspx`는 hidden field 직렬화 형식(`†`, `‡`)에 의존한다. `custom.js`의 컬럼 순서와 서버의 파싱 순서를 같이 유지해야 한다.
- `group/usermanage.aspx.cs`의 이전 구성원 이관 쿼리에는 특정 수양회 코드 fallback이 하드코딩된 부분이 있다. 이관 로직 변경 전 실제 DB 데이터를 확인한다.
- `staff/status.aspx.cs`의 참석현황 계산은 `etc2`와 회원구분 조건에 강하게 의존한다. 참석 관련 수정 시 전체/요회별 카운트가 맞는지 수동 검증한다.
- `System.Drawing` 기반 이미지 리사이즈를 서버에서 수행한다. IIS 권한, GDI+ 제한, 큰 이미지 업로드 시 메모리 사용량을 고려한다.
- `CodeHelper.Redirect()`는 `Response.End()`를 호출하므로 이후 코드가 실행되지 않는 전제에 맞춰 작성되어 있다.
- 내부 URL은 extensionless canonical을 기준으로 한다. 신규 링크/리다이렉트/JS 이동 코드에 `.aspx`를 직접 넣지 않는다.
- DB의 `menu_master.menu_path`는 기존 `.aspx` 경로와 매칭하므로, 권한/메뉴 조회 로직을 바꿀 때 `GetCurrentMenuPath()`와 `ToCanonicalUrl()`의 역할을 분리해서 유지한다.

## 최소 테스트 시나리오

수정 후 최소한 아래를 브라우저에서 확인한다.

1. 비로그인 상태에서 `/` 접속, 로그인/회원가입 링크 확인
2. 회원가입 후 관리자 화면에서 승인 처리
3. `user` 역할로 자기 요회 구성원 추가/수정/삭제
4. `manager` 역할로 등록확인 체크 저장
5. 수입 등록, 증빙 이미지 업로드/교체/삭제
6. 지출 등록, 영수증 이미지 업로드/교체/삭제
7. 등록현황, 수입·지출현황, 참석현황 숫자 확인
8. 등록현황 엑셀, 수입/지출 엑셀 다운로드
9. 수입/지출 상세 인쇄와 전체 인쇄
10. 수양회/회비/요회 마스터 삭제 제한 동작 확인
11. `admin` 또는 `manager`로 상단 `수양회 전환` 모달에서 과거 수양회로 전환 후 안내 문구와 주요 화면 기준 데이터 확인
12. 최신 수양회로 다시 전환했을 때 과거 수양회 안내 문구가 사라지는지 확인
13. `/member/login.aspx`, `/staff/income.aspx`, `/default` 접근 시 각각 `/member/login`, `/staff/income`, `/`로 정규화되는지 확인
14. 주요 메뉴/탭/엑셀/인쇄 링크가 `.aspx` 없는 URL로 이동하는지 확인
15. 데스크톱·모바일·카카오톡 등 인앱 브라우저에서 `/retreat_program_viewer`가 PDF를 canvas로 표시하고 페이지 이동·확대·축소·파일 저장이 동작하는지 확인

## 현재 소스 기준 주요 진입 URL

| URL | 기능 |
| --- | --- |
| `/` | 활성 수양회 안내 |
| `/member/login` | 로그인 |
| `/member/join` | 회원가입 |
| `/info/modify01` | 내 정보 수정 |
| `/manage/members` | 회원 관리 |
| `/manage/groups` | 요회 관리 |
| `/group/usermanage` | 요회 구성원·회비 관리 |
| `/staff/retreat` | 수양회 관리 |
| `/staff/retreatdues` | 수양회비 구분 관리 |
| `/staff/registatus` | 실무자 등록 확인 |
| `/staff/income` | 수입 관리 |
| `/staff/expenses` | 지출 관리 |
| `/staff/items` | 수입/지출 코드 관리 |
| `/staff/status` | 종합 현황 |
| `/staff/mealstatus` | 식사수량 현황·사전설정 (`manager`, `admin`) |
| `/staff/mealstatus_excel_export` | 활성 수양회 전체 요회 식사 선택 상세 엑셀 (`manager`, `admin`) |
| `/meal-precheck` | 비로그인 식사여부 사전조사 |
| `/retreat_program_viewer` | 모바일·인앱 브라우저 대응 프로그램 PDF.js 뷰어 |
