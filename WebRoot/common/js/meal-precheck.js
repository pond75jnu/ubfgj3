(function () {
    "use strict";

    var dirty = false;
    var saving = false;

    function checkboxList() {
        return Array.prototype.slice.call(document.querySelectorAll("[data-meal-survey-checkbox]"));
    }

    function updateSelectionCount() {
        var output = document.querySelector("[data-meal-selection-count]");
        if (!output) {
            return;
        }

        output.textContent = checkboxList().filter(function (checkbox) {
            return checkbox.checked;
        }).length.toLocaleString("ko-KR");
    }

    function updateMemberToggle(toggle) {
        var row = toggle.closest(".site-meal-member-card");
        if (!row) {
            return;
        }

        var checkboxes = Array.prototype.slice.call(row.querySelectorAll("[data-meal-survey-checkbox]"));
        var allSelected = checkboxes.length > 0 && checkboxes.every(function (checkbox) {
            return checkbox.checked;
        });
        toggle.textContent = allSelected ? "전체해제" : "전체선택";
        toggle.setAttribute("aria-pressed", allSelected ? "true" : "false");
    }

    function updateToggleForCheckbox(checkbox) {
        var row = checkbox.closest(".site-meal-member-card");
        var toggle = row ? row.querySelector("[data-meal-member-toggle]") : null;
        if (toggle) {
            updateMemberToggle(toggle);
        }
    }

    window.mealPrecheckConfirmEmptySelection = function () {
        saving = true;
        var hasSelection = checkboxList().some(function (checkbox) {
            return checkbox.checked;
        });

        if (hasSelection || window.confirm("선택한 식사가 없습니다. 이 요회의 모든 식사를 미참여로 저장할까요?")) {
            return true;
        }

        saving = false;
        return false;
    };

    window.mealPrecheckValidateNewMember = function () {
        var modal = document.querySelector("[data-meal-add-member-modal]");
        var nameInput = modal ? modal.querySelector("input[type='text']") : null;
        if (!nameInput || !nameInput.value.trim()) {
            window.alert("성명을 입력하세요.");
            if (nameInput) {
                nameInput.focus();
            }
            return false;
        }

        if (dirty && !window.confirm("저장하지 않은 식사 선택이 있습니다. 신규인원을 추가하면 현재 변경사항은 사라집니다. 계속할까요?")) {
            return false;
        }

        saving = true;
        return true;
    };

    function initializeSurvey() {
        checkboxList().forEach(function (checkbox) {
            checkbox.addEventListener("change", function () {
                dirty = true;
                updateSelectionCount();
                updateToggleForCheckbox(checkbox);
            });
        });

        Array.prototype.slice.call(document.querySelectorAll("[data-meal-member-toggle]")).forEach(function (toggle) {
            toggle.addEventListener("click", function () {
                var row = toggle.closest(".site-meal-member-card");
                var checkboxes = row
                    ? Array.prototype.slice.call(row.querySelectorAll("[data-meal-survey-checkbox]"))
                    : [];
                var shouldSelect = !checkboxes.every(function (checkbox) {
                    return checkbox.checked;
                });

                checkboxes.forEach(function (checkbox) {
                    checkbox.checked = shouldSelect;
                });
                if (checkboxes.length > 0) {
                    dirty = true;
                }
                updateMemberToggle(toggle);
                updateSelectionCount();
            });
            updateMemberToggle(toggle);
        });

        Array.prototype.slice.call(document.querySelectorAll("[data-meal-save-button]")).forEach(function (button) {
            button.addEventListener("click", function () {
                saving = true;
            });
        });

        var groupSelect = document.querySelector("[data-meal-group-select]");
        if (groupSelect) {
            groupSelect.addEventListener("focus", function () {
                groupSelect.setAttribute("data-previous-value", groupSelect.value);
            });
            groupSelect.addEventListener("change", function (event) {
                if (!dirty || window.confirm("저장하지 않은 변경사항이 있습니다. 요회를 변경할까요?")) {
                    saving = true;
                    return;
                }

                var previous = groupSelect.getAttribute("data-previous-value");
                if (previous !== null) {
                    groupSelect.value = previous;
                }
                event.preventDefault();
                event.stopImmediatePropagation();
            }, true);
        }

        window.addEventListener("beforeunload", function (event) {
            if (!dirty || saving) {
                return;
            }
            event.preventDefault();
            event.returnValue = "";
        });

        updateSelectionCount();
    }

    function initializeModal() {
        var modal = document.querySelector("[data-meal-modal]");
        if (!modal) {
            return;
        }

        var dialog = modal.querySelector("[data-meal-modal-dialog]");
        var closeButtons = modal.querySelectorAll("[data-meal-modal-close]");
        var focusableSelector = "a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])";

        function closeModal() {
            var returnGroup = modal.getAttribute("data-meal-return-group");
            modal.style.display = "none";
            modal.setAttribute("aria-hidden", "true");
            document.body.classList.remove("site-meal-modal-open");
            if (returnGroup) {
                var triggers = document.getElementsByName("detailGroup");
                Array.prototype.some.call(triggers, function (trigger) {
                    if (trigger.value === returnGroup) {
                        trigger.focus();
                        return true;
                    }
                    return false;
                });
            }
        }

        Array.prototype.slice.call(closeButtons).forEach(function (button) {
            button.addEventListener("click", closeModal);
        });

        modal.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                closeModal();
                return;
            }
            if (event.key !== "Tab" || !dialog) {
                return;
            }

            var focusable = Array.prototype.slice.call(dialog.querySelectorAll(focusableSelector));
            if (!focusable.length) {
                return;
            }
            var first = focusable[0];
            var last = focusable[focusable.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            }
        });

        document.body.classList.add("site-meal-modal-open");
        var firstControl = dialog ? dialog.querySelector(focusableSelector) : null;
        if (firstControl) {
            window.setTimeout(function () { firstControl.focus(); }, 0);
        }
    }

    function initializeAddMemberModal() {
        var modal = document.querySelector("[data-meal-add-member-modal]");
        var openButton = document.querySelector("[data-meal-add-member-open]");
        if (!modal || !openButton) {
            return;
        }

        var dialog = modal.querySelector("[data-meal-add-member-dialog]");
        var closeButtons = modal.querySelectorAll("[data-meal-add-member-close]");
        var focusableSelector = "a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])";

        function openModal() {
            modal.removeAttribute("hidden");
            document.body.classList.add("site-meal-modal-open");
            var nameInput = modal.querySelector("input[type='text']");
            if (nameInput) {
                window.setTimeout(function () { nameInput.focus(); }, 0);
            }
        }

        function closeModal() {
            modal.setAttribute("hidden", "hidden");
            document.body.classList.remove("site-meal-modal-open");
            openButton.focus();
        }

        openButton.addEventListener("click", openModal);
        Array.prototype.slice.call(closeButtons).forEach(function (button) {
            button.addEventListener("click", closeModal);
        });

        modal.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                closeModal();
                return;
            }
            if (event.key !== "Tab" || !dialog) {
                return;
            }

            var focusable = Array.prototype.slice.call(dialog.querySelectorAll(focusableSelector));
            if (!focusable.length) {
                return;
            }
            var first = focusable[0];
            var last = focusable[focusable.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            }
        });

        if (!modal.hasAttribute("hidden")) {
            document.body.classList.add("site-meal-modal-open");
            var firstControl = dialog ? dialog.querySelector(focusableSelector) : null;
            if (firstControl) {
                window.setTimeout(function () { firstControl.focus(); }, 0);
            }
        }
    }

    function scrollToNewMember() {
        var member = document.querySelector("[data-meal-new-member]");
        if (!member) {
            return;
        }

        var reduceMotion = window.matchMedia
            && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
        window.setTimeout(function () {
            member.scrollIntoView({
                behavior: reduceMotion ? "auto" : "smooth",
                block: "center",
                inline: "nearest"
            });
            try {
                member.focus({ preventScroll: true });
            } catch (error) {
                member.focus();
            }
        }, 120);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            initializeSurvey();
            initializeModal();
            initializeAddMemberModal();
            scrollToNewMember();
        });
    } else {
        initializeSurvey();
        initializeModal();
        initializeAddMemberModal();
        scrollToNewMember();
    }
}());
