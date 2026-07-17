import * as pdfjsLib from "/common/vendor/pdfjs-4.10.38/build/pdf.min.mjs";

pdfjsLib.GlobalWorkerOptions.workerSrc = "/common/vendor/pdfjs-4.10.38/build/pdf.worker.min.mjs";

var root = document.querySelector("[data-program-viewer]");

if (root) {
    root.setAttribute("data-viewer-started", "true");

    var sourceUrl = root.getAttribute("data-source-url") || "/retreat_program";
    var scrollArea = root.querySelector("[data-viewer-scroll]");
    var loadingPanel = root.querySelector("[data-viewer-loading]");
    var errorPanel = root.querySelector("[data-viewer-error]");
    var errorMessage = root.querySelector("[data-viewer-error-message]");
    var retryButton = root.querySelector("[data-viewer-retry]");
    var pagesContainer = root.querySelector("[data-viewer-pages]");
    var imageContainer = root.querySelector("[data-viewer-image]");
    var imageElement = root.querySelector("[data-viewer-image-element]");
    var documentStatus = root.querySelector("[data-document-status]");
    var pageInput = root.querySelector("[data-page-input]");
    var pageTotal = root.querySelector("[data-page-total]");
    var previousButton = root.querySelector("[data-page-prev]");
    var nextButton = root.querySelector("[data-page-next]");
    var zoomOutButton = root.querySelector("[data-zoom-out]");
    var zoomInButton = root.querySelector("[data-zoom-in]");
    var zoomFitButton = root.querySelector("[data-zoom-fit]");
    var zoomLabel = root.querySelector("[data-zoom-label]");

    var state = {
        pdf: null,
        entries: [],
        visiblePages: new Set(),
        currentPage: 1,
        zoom: 1,
        observer: null,
        imageUrl: null,
        scrollTicking: false,
        resizeTimer: null
    };

    if (window.self !== window.top) {
        document.documentElement.classList.add("is-embedded-viewer");
    }

    function setLoading(message) {
        loadingPanel.hidden = false;
        errorPanel.hidden = true;
        pagesContainer.hidden = true;
        imageContainer.hidden = true;
        documentStatus.textContent = message || "문서를 불러오는 중입니다.";
    }

    function setControlsEnabled(enabled) {
        pageInput.disabled = !enabled;
        previousButton.disabled = !enabled || state.currentPage <= 1;
        nextButton.disabled = !enabled || !state.pdf || state.currentPage >= state.pdf.numPages;
        zoomOutButton.disabled = !enabled || state.zoom <= 0.75;
        zoomInButton.disabled = !enabled || state.zoom >= 2.5;
        zoomFitButton.disabled = !enabled;
    }

    function showError(message) {
        loadingPanel.hidden = true;
        pagesContainer.hidden = true;
        imageContainer.hidden = true;
        errorMessage.textContent = message || "문서를 불러오는 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.";
        errorPanel.hidden = false;
        documentStatus.textContent = "문서를 표시하지 못했습니다.";
        setControlsEnabled(false);
    }

    function releaseCurrentDocument() {
        if (state.observer) {
            state.observer.disconnect();
            state.observer = null;
        }

        state.entries.forEach(function (entry) {
            if (entry.renderTask) {
                entry.renderTask.cancel();
            }
        });

        if (state.pdf) {
            state.pdf.destroy();
        }

        if (state.imageUrl) {
            URL.revokeObjectURL(state.imageUrl);
        }

        state.pdf = null;
        state.entries = [];
        state.visiblePages.clear();
        state.currentPage = 1;
        state.zoom = 1;
        state.imageUrl = null;
        pagesContainer.textContent = "";
        imageElement.removeAttribute("src");
        pageInput.value = "1";
        pageTotal.textContent = "0";
        zoomLabel.textContent = "너비 맞춤";
    }

    function isPdf(bytes, contentType) {
        if (contentType.indexOf("application/pdf") === 0) {
            return true;
        }

        return bytes.length >= 5
            && bytes[0] === 0x25
            && bytes[1] === 0x50
            && bytes[2] === 0x44
            && bytes[3] === 0x46
            && bytes[4] === 0x2d;
    }

    async function loadDocument() {
        releaseCurrentDocument();
        setControlsEnabled(false);
        setLoading("문서를 불러오는 중입니다.");

        try {
            var response = await fetch(sourceUrl, {
                credentials: "same-origin",
                cache: "no-store",
                headers: { "Accept": "application/pdf,image/*" }
            });

            if (!response.ok) {
                throw new Error("HTTP " + response.status);
            }

            var contentType = (response.headers.get("Content-Type") || "").toLowerCase();
            var buffer = await response.arrayBuffer();
            var bytes = new Uint8Array(buffer);

            if (contentType.indexOf("image/") === 0) {
                showImage(new Blob([bytes], { type: contentType }));
                return;
            }

            if (!isPdf(bytes, contentType)) {
                throw new Error("Unsupported document type");
            }

            documentStatus.textContent = "PDF 문서를 분석하는 중입니다.";

            var loadingTask = pdfjsLib.getDocument({
                data: bytes,
                cMapUrl: "/common/vendor/pdfjs-4.10.38/cmaps/",
                cMapPacked: true,
                standardFontDataUrl: "/common/vendor/pdfjs-4.10.38/standard_fonts/",
                isEvalSupported: false,
                useWorkerFetch: true
            });

            state.pdf = await loadingTask.promise;
            await preparePdfPages();
        } catch (error) {
            console.error("Retreat program viewer error", error);
            showError("프로그램 문서를 표시할 수 없습니다. 네트워크 상태를 확인한 뒤 다시 시도해 주세요.");
        }
    }

    function showImage(blob) {
        state.imageUrl = URL.createObjectURL(blob);
        imageElement.src = state.imageUrl;
        imageContainer.hidden = false;
        loadingPanel.hidden = true;
        errorPanel.hidden = true;
        documentStatus.textContent = "프로그램 안내 이미지";
        pageInput.value = "1";
        pageTotal.textContent = "1";
        setControlsEnabled(false);
    }

    function availablePageWidth() {
        var horizontalPadding = window.innerWidth <= 640 ? 16 : 40;
        return Math.max(240, scrollArea.clientWidth - horizontalPadding);
    }

    function pageViewport(entry) {
        var baseViewport = entry.page.getViewport({ scale: 1 });
        var fitScale = availablePageWidth() / baseViewport.width;
        return entry.page.getViewport({ scale: fitScale * state.zoom });
    }

    function layoutPage(entry) {
        var viewport = pageViewport(entry);
        entry.element.style.width = Math.ceil(viewport.width) + "px";
        entry.canvas.style.width = Math.ceil(viewport.width) + "px";
        entry.canvas.style.height = Math.ceil(viewport.height) + "px";
        entry.canvasWrapper.style.minHeight = Math.ceil(viewport.height) + "px";
    }

    async function preparePdfPages() {
        var fragment = document.createDocumentFragment();

        for (var pageNumber = 1; pageNumber <= state.pdf.numPages; pageNumber += 1) {
            var page = await state.pdf.getPage(pageNumber);
            var pageElement = document.createElement("section");
            var pageLabel = document.createElement("span");
            var canvasWrapper = document.createElement("div");
            var canvas = document.createElement("canvas");

            pageElement.className = "program-viewer-page";
            pageElement.setAttribute("data-page-number", String(pageNumber));
            pageElement.setAttribute("aria-label", pageNumber + "페이지");
            pageLabel.className = "program-viewer-page-label";
            pageLabel.textContent = pageNumber + " / " + state.pdf.numPages;
            canvasWrapper.className = "program-viewer-canvas-wrap";
            canvas.setAttribute("aria-label", pageNumber + "페이지 내용");
            canvasWrapper.appendChild(canvas);
            pageElement.appendChild(pageLabel);
            pageElement.appendChild(canvasWrapper);
            fragment.appendChild(pageElement);

            var entry = {
                pageNumber: pageNumber,
                page: page,
                element: pageElement,
                canvasWrapper: canvasWrapper,
                canvas: canvas,
                renderTask: null,
                renderVersion: 0,
                renderedZoom: 0,
                renderedWidth: 0
            };

            state.entries.push(entry);
            layoutPage(entry);
        }

        pagesContainer.appendChild(fragment);
        pageInput.max = String(state.pdf.numPages);
        pageTotal.textContent = String(state.pdf.numPages);
        pagesContainer.hidden = false;
        loadingPanel.hidden = true;
        errorPanel.hidden = true;
        documentStatus.textContent = state.pdf.numPages + "페이지 PDF";
        setControlsEnabled(true);
        observePages();
        updateCurrentPage();
    }

    async function renderPage(entry) {
        var width = availablePageWidth();

        if (entry.renderedZoom === state.zoom && entry.renderedWidth === width) {
            return;
        }

        entry.renderVersion += 1;
        var renderVersion = entry.renderVersion;

        if (entry.renderTask) {
            var previousRenderTask = entry.renderTask;
            previousRenderTask.cancel();

            try {
                await previousRenderTask.promise;
            } catch (cancelError) {
                if (!cancelError || cancelError.name !== "RenderingCancelledException") {
                    console.error("PDF page render cancellation error", cancelError);
                }
            }

            if (entry.renderVersion !== renderVersion) {
                return;
            }
        }

        var viewport = pageViewport(entry);
        var outputScale = Math.min(window.devicePixelRatio || 1, 2);
        var maximumPixels = 16000000;
        var requestedPixels = viewport.width * viewport.height * outputScale * outputScale;

        if (requestedPixels > maximumPixels) {
            outputScale *= Math.sqrt(maximumPixels / requestedPixels);
        }

        var canvas = entry.canvas;
        var context = canvas.getContext("2d", { alpha: false });
        canvas.width = Math.max(1, Math.floor(viewport.width * outputScale));
        canvas.height = Math.max(1, Math.floor(viewport.height * outputScale));
        canvas.style.width = Math.ceil(viewport.width) + "px";
        canvas.style.height = Math.ceil(viewport.height) + "px";
        entry.canvasWrapper.style.minHeight = Math.ceil(viewport.height) + "px";

        entry.renderTask = entry.page.render({
            canvasContext: context,
            viewport: viewport,
            transform: outputScale === 1 ? null : [outputScale, 0, 0, outputScale, 0, 0]
        });

        try {
            await entry.renderTask.promise;
            if (entry.renderVersion === renderVersion) {
                entry.renderedZoom = state.zoom;
                entry.renderedWidth = width;
                entry.element.classList.add("is-rendered");
            }
        } catch (error) {
            if (!error || error.name !== "RenderingCancelledException") {
                console.error("PDF page render error", error);
            }
        } finally {
            if (entry.renderVersion === renderVersion) {
                entry.renderTask = null;
            }
        }
    }

    function observePages() {
        if (!("IntersectionObserver" in window)) {
            state.entries.forEach(function (entry) {
                renderPage(entry);
            });
            return;
        }

        state.observer = new IntersectionObserver(function (changes) {
            changes.forEach(function (change) {
                var pageNumber = Number(change.target.getAttribute("data-page-number"));
                var entry = state.entries[pageNumber - 1];

                if (change.isIntersecting) {
                    state.visiblePages.add(pageNumber);
                    renderPage(entry);
                } else {
                    state.visiblePages.delete(pageNumber);
                }
            });
        }, {
            root: scrollArea,
            rootMargin: "900px 0px",
            threshold: 0.01
        });

        state.entries.forEach(function (entry) {
            state.observer.observe(entry.element);
        });
    }

    function updateCurrentPage() {
        if (!state.entries.length) {
            return;
        }

        var targetTop = scrollArea.scrollTop + 32;
        var closestEntry = state.entries[0];
        var closestDistance = Math.abs(closestEntry.element.offsetTop - targetTop);

        state.entries.forEach(function (entry) {
            var distance = Math.abs(entry.element.offsetTop - targetTop);
            if (distance < closestDistance) {
                closestEntry = entry;
                closestDistance = distance;
            }
        });

        state.currentPage = closestEntry.pageNumber;
        pageInput.value = String(state.currentPage);
        previousButton.disabled = state.currentPage <= 1;
        nextButton.disabled = state.currentPage >= state.entries.length;
    }

    function scrollToPage(pageNumber) {
        if (!state.entries.length) {
            return;
        }

        var safePage = Math.min(state.entries.length, Math.max(1, pageNumber));
        state.entries[safePage - 1].element.scrollIntoView({ block: "start", behavior: "smooth" });
        state.currentPage = safePage;
        pageInput.value = String(safePage);
        previousButton.disabled = safePage <= 1;
        nextButton.disabled = safePage >= state.entries.length;
    }

    function setZoom(nextZoom) {
        if (!state.pdf) {
            return;
        }

        state.zoom = Math.min(2.5, Math.max(0.75, nextZoom));
        zoomLabel.textContent = state.zoom === 1 ? "너비 맞춤" : Math.round(state.zoom * 100) + "%";
        zoomOutButton.disabled = state.zoom <= 0.75;
        zoomInButton.disabled = state.zoom >= 2.5;

        state.entries.forEach(function (entry) {
            entry.renderedZoom = 0;
            layoutPage(entry);
        });

        state.visiblePages.forEach(function (pageNumber) {
            renderPage(state.entries[pageNumber - 1]);
        });
    }

    scrollArea.addEventListener("scroll", function () {
        if (state.scrollTicking) {
            return;
        }

        state.scrollTicking = true;
        window.requestAnimationFrame(function () {
            updateCurrentPage();
            state.scrollTicking = false;
        });
    }, { passive: true });

    previousButton.addEventListener("click", function () {
        scrollToPage(state.currentPage - 1);
    });

    nextButton.addEventListener("click", function () {
        scrollToPage(state.currentPage + 1);
    });

    pageInput.addEventListener("change", function () {
        scrollToPage(Number(pageInput.value) || 1);
    });

    zoomOutButton.addEventListener("click", function () {
        setZoom(state.zoom - 0.25);
    });

    zoomInButton.addEventListener("click", function () {
        setZoom(state.zoom + 0.25);
    });

    zoomFitButton.addEventListener("click", function () {
        setZoom(1);
    });

    retryButton.addEventListener("click", loadDocument);

    window.addEventListener("resize", function () {
        window.clearTimeout(state.resizeTimer);
        state.resizeTimer = window.setTimeout(function () {
            if (!state.pdf) {
                return;
            }

            state.entries.forEach(function (entry) {
                entry.renderedWidth = 0;
                layoutPage(entry);
            });

            state.visiblePages.forEach(function (pageNumber) {
                renderPage(state.entries[pageNumber - 1]);
            });
        }, 180);
    });

    window.addEventListener("beforeunload", releaseCurrentDocument);
    loadDocument();
}
