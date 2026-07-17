(function () {
    function showFallback() {
        var root = document.querySelector("[data-program-viewer]");
        if (!root || root.getAttribute("data-viewer-started") === "true") {
            return;
        }

        var loading = root.querySelector("[data-viewer-loading]");
        var error = root.querySelector("[data-viewer-error]");
        var message = root.querySelector("[data-viewer-error-message]");
        var status = root.querySelector("[data-document-status]");

        if (loading) {
            loading.hidden = true;
        }
        if (message) {
            message.textContent = "이 브라우저에서는 사이트 전용 뷰어를 시작할 수 없습니다. 원본 파일 열기 또는 파일 저장을 이용해 주세요.";
        }
        if (error) {
            error.hidden = false;
        }
        if (status) {
            status.textContent = "브라우저 호환 모드";
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            window.setTimeout(showFallback, 8000);
        });
    } else {
        window.setTimeout(showFallback, 8000);
    }
}());
