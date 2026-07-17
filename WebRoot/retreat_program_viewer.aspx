<%@ Page Language="C#" AutoEventWireup="true" CodeFile="retreat_program_viewer.aspx.cs" Inherits="retreat_program_viewer" %>
<!doctype html>
<html lang="ko">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <meta name="color-scheme" content="light" />
    <title>수양회 프로그램 세부보기</title>
    <link rel="stylesheet" href="/common/css/retreat-program-viewer.css?v=pdfjs-01" />
</head>
<body>
    <div class="program-viewer" data-program-viewer data-source-url="/retreat_program">
        <header class="program-viewer-toolbar">
            <div class="program-viewer-heading">
                <strong>프로그램 세부보기</strong>
                <span data-document-status>문서를 불러오는 중입니다.</span>
            </div>

            <div class="program-viewer-controls" role="toolbar" aria-label="문서 보기 도구">
                <div class="program-viewer-control-group" aria-label="페이지 이동">
                    <button type="button" class="program-viewer-icon-button" data-page-prev aria-label="이전 페이지" disabled>&lsaquo;</button>
                    <label class="program-viewer-page-field">
                        <span class="sr-only">현재 페이지</span>
                        <input type="number" min="1" value="1" inputmode="numeric" data-page-input disabled />
                        <span aria-hidden="true">/</span>
                        <span data-page-total>0</span>
                    </label>
                    <button type="button" class="program-viewer-icon-button" data-page-next aria-label="다음 페이지" disabled>&rsaquo;</button>
                </div>

                <div class="program-viewer-control-group" aria-label="화면 배율">
                    <button type="button" class="program-viewer-icon-button" data-zoom-out aria-label="축소" disabled>&minus;</button>
                    <button type="button" class="program-viewer-zoom-label" data-zoom-fit aria-label="화면 너비에 맞추기" disabled>
                        <span data-zoom-label>너비 맞춤</span>
                    </button>
                    <button type="button" class="program-viewer-icon-button" data-zoom-in aria-label="확대" disabled>+</button>
                </div>

                <a class="program-viewer-download" href="/retreat_program?download=1" aria-label="프로그램 파일 저장">파일 저장</a>
            </div>
        </header>

        <main class="program-viewer-scroll" data-viewer-scroll tabindex="0">
            <div class="program-viewer-loading" data-viewer-loading role="status" aria-live="polite">
                <span class="program-viewer-spinner" aria-hidden="true"></span>
                <p>프로그램 문서를 준비하고 있습니다.</p>
            </div>

            <section class="program-viewer-error" data-viewer-error hidden role="alert">
                <strong>문서를 표시하지 못했습니다.</strong>
                <p data-viewer-error-message>잠시 후 다시 시도해 주세요.</p>
                <div>
                    <button type="button" data-viewer-retry>다시 시도</button>
                    <a href="/retreat_program" target="_blank" rel="noopener">원본 파일 열기</a>
                    <a href="/retreat_program?download=1">파일 저장</a>
                </div>
            </section>

            <div class="program-viewer-pages" data-viewer-pages hidden aria-label="PDF 페이지"></div>
            <div class="program-viewer-image" data-viewer-image hidden>
                <img alt="수양회 프로그램 안내 이미지" data-viewer-image-element />
            </div>
        </main>
    </div>

    <script type="module" src="/common/js/retreat-program-viewer.js?v=pdfjs-01"></script>
    <script defer src="/common/js/retreat-program-viewer-fallback.js?v=pdfjs-01"></script>
</body>
</html>
