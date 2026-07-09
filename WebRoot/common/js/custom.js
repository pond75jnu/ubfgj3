String.prototype.trim = function () { return this.replace(/(^\s*)|(\s*$)/gi, ""); }

document.addEventListener("DOMContentLoaded", function () {
    var nav = document.querySelector("[data-site-nav]");
    if (!nav) {
        return;
    }

    var toggle = nav.querySelector("[data-site-nav-toggle]");
    var menu = nav.querySelector("[data-site-nav-menu]");
    var dropdownToggles = nav.querySelectorAll("[data-site-dropdown-toggle]");

    function resetDropdownAlignment(dropdown) {
        dropdown.classList.remove("site-nav-dropdown-align-start", "site-nav-dropdown-align-end");
    }

    function adjustDropdownAlignment(dropdown) {
        var dropdownMenu = dropdown.querySelector(".site-nav-dropdown-menu");
        if (!dropdownMenu || window.matchMedia("(max-width: 833px)").matches) {
            resetDropdownAlignment(dropdown);
            return;
        }

        resetDropdownAlignment(dropdown);

        window.requestAnimationFrame(function () {
            var rect = dropdownMenu.getBoundingClientRect();
            var safeGap = 16;

            if (rect.left < safeGap) {
                dropdown.classList.add("site-nav-dropdown-align-start");
            } else if (rect.right > window.innerWidth - safeGap) {
                dropdown.classList.add("site-nav-dropdown-align-end");
            }
        });
    }

    if (toggle && menu) {
        toggle.addEventListener("click", function () {
            var isOpen = nav.classList.toggle("is-open");
            toggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
            toggle.setAttribute("aria-label", isOpen ? "메뉴 닫기" : "메뉴 열기");
        });
    }

    dropdownToggles.forEach(function (item) {
        item.addEventListener("click", function (event) {
            var parent = item.closest(".site-nav-dropdown");
            if (!parent) {
                return;
            }

            event.preventDefault();

            nav.querySelectorAll(".site-nav-dropdown.is-open").forEach(function (openItem) {
                if (openItem !== parent) {
                    openItem.classList.remove("is-open");
                    var openToggle = openItem.querySelector("[data-site-dropdown-toggle]");
                    if (openToggle) {
                        openToggle.setAttribute("aria-expanded", "false");
                    }
                }
            });

            var isOpen = parent.classList.toggle("is-open");
            item.setAttribute("aria-expanded", isOpen ? "true" : "false");
            if (isOpen) {
                adjustDropdownAlignment(parent);
            } else {
                resetDropdownAlignment(parent);
            }
        });
    });

    document.addEventListener("click", function (event) {
        if (nav.contains(event.target)) {
            return;
        }

        nav.classList.remove("is-open");
        if (toggle) {
            toggle.setAttribute("aria-expanded", "false");
            toggle.setAttribute("aria-label", "메뉴 열기");
        }

        nav.querySelectorAll(".site-nav-dropdown.is-open").forEach(function (openItem) {
            openItem.classList.remove("is-open");
            var openToggle = openItem.querySelector("[data-site-dropdown-toggle]");
            if (openToggle) {
                openToggle.setAttribute("aria-expanded", "false");
            }
        });
    });

    document.addEventListener("keydown", function (event) {
        if (event.key !== "Escape") {
            return;
        }

        nav.classList.remove("is-open");
        if (toggle) {
            toggle.setAttribute("aria-expanded", "false");
            toggle.setAttribute("aria-label", "메뉴 열기");
            toggle.focus();
        }

        nav.querySelectorAll(".site-nav-dropdown.is-open").forEach(function (openItem) {
            openItem.classList.remove("is-open");
            var openToggle = openItem.querySelector("[data-site-dropdown-toggle]");
            if (openToggle) {
                openToggle.setAttribute("aria-expanded", "false");
            }
        });
    });
});

document.addEventListener("DOMContentLoaded", function () {
    var modal = document.querySelector("[data-retreat-switch-modal]");
    if (!modal) {
        return;
    }

    var openButtons = document.querySelectorAll("[data-retreat-switch-open]");
    var closeButtons = modal.querySelectorAll("[data-retreat-switch-close]");
    var select = modal.querySelector("select");

    function openModal() {
        modal.style.display = "flex";
        modal.classList.add("is-open");
        document.body.classList.add("site-modal-open");
        if (select) {
            select.focus();
        }
    }

    function closeModal() {
        modal.classList.remove("is-open");
        modal.style.display = "none";
        document.body.classList.remove("site-modal-open");
    }

    openButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            openModal();
        });
    });

    closeButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            closeModal();
        });
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && modal.classList.contains("is-open")) {
            closeModal();
        }
    });
});

document.addEventListener("DOMContentLoaded", function () {
    var modal = document.querySelector("[data-retreat-program-modal]");
    if (!modal) {
        return;
    }

    var openLinks = document.querySelectorAll("[data-retreat-program-open]");
    var closeButtons = modal.querySelectorAll("[data-retreat-program-close]");
    var dialog = modal.querySelector("[data-retreat-program-dialog]");
    var frame = modal.querySelector("[data-retreat-program-frame]");
    var closeButton = modal.querySelector(".site-program-close");
    var lastActiveElement = null;
    var desktopModalQuery = window.matchMedia("(min-width: 834px)");

    function setDialogToolsEnabled(enabled) {
        if (!window.jQuery || !dialog) {
            return;
        }

        var $dialog = window.jQuery(dialog);

        if ($dialog.data("ui-draggable")) {
            $dialog.draggable(enabled ? "enable" : "disable");
        }

        if ($dialog.data("ui-resizable")) {
            $dialog.resizable(enabled ? "enable" : "disable");
        }
    }

    function resetDialogForMobile() {
        if (!dialog) {
            return;
        }

        dialog.style.left = "";
        dialog.style.top = "";
        dialog.style.width = "";
        dialog.style.height = "";
    }

    function initDialogTools() {
        if (!window.jQuery || !window.jQuery.fn.draggable || !window.jQuery.fn.resizable || !dialog) {
            return;
        }

        var $dialog = window.jQuery(dialog);

        if (!$dialog.data("retreat-program-tools-ready")) {
            $dialog.draggable({
                handle: ".site-program-header",
                cancel: ".site-program-close, .site-program-actions, a, button, iframe",
                containment: "window",
                start: function () {
                    dialog.classList.add("ui-draggable-dragging");
                },
                stop: function () {
                    dialog.classList.remove("ui-draggable-dragging");
                }
            });

            $dialog.resizable({
                handles: "n,e,s,w,se,sw,ne,nw",
                minWidth: 420,
                minHeight: 360,
                start: function () {
                    $dialog.resizable("option", "maxWidth", Math.max(420, window.innerWidth - 24));
                    $dialog.resizable("option", "maxHeight", Math.max(360, window.innerHeight - 24));
                    dialog.classList.add("ui-resizable-resizing");
                },
                stop: function () {
                    dialog.classList.remove("ui-resizable-resizing");
                }
            });

            $dialog.data("retreat-program-tools-ready", true);
        }

        if (desktopModalQuery.matches) {
            setDialogToolsEnabled(true);
        } else {
            setDialogToolsEnabled(false);
            resetDialogForMobile();
        }
    }

    function openModal(event, link) {
        if (event) {
            event.preventDefault();
        }

        lastActiveElement = link || document.activeElement;

        if (frame) {
            frame.setAttribute("src", (link && link.getAttribute("href")) || "/retreat_program");
        }

        modal.style.display = "flex";
        modal.classList.add("is-open");
        document.body.classList.add("site-modal-open");
        initDialogTools();

        if (closeButton) {
            closeButton.focus();
        }
    }

    function closeModal() {
        modal.classList.remove("is-open");
        modal.style.display = "none";
        document.body.classList.remove("site-modal-open");

        if (frame) {
            frame.setAttribute("src", "about:blank");
        }

        if (lastActiveElement && typeof lastActiveElement.focus === "function") {
            lastActiveElement.focus();
        }
    }

    openLinks.forEach(function (link) {
        link.addEventListener("click", function (event) {
            openModal(event, link);
        });
    });

    closeButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            closeModal();
        });
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && modal.classList.contains("is-open")) {
            closeModal();
        }
    });

    function handleModalViewportChange() {
        if (desktopModalQuery.matches) {
            setDialogToolsEnabled(true);
        } else {
            setDialogToolsEnabled(false);
            resetDialogForMobile();
        }
    }

    if (typeof desktopModalQuery.addEventListener === "function") {
        desktopModalQuery.addEventListener("change", handleModalViewportChange);
    } else if (typeof desktopModalQuery.addListener === "function") {
        desktopModalQuery.addListener(handleModalViewportChange);
    }
});

function confirmRetreatSwitch() {
    var select = document.querySelector("[data-retreat-switch-modal] select");
    if (!select || select.value === "") {
        alert("전환할 수양회를 선택하십시오.");
        return false;
    }

    return confirm("선택한 수양회를 사용 상태로 전환하시겠습니까?\n\n전환하면 시스템 전체가 해당 수양회 기준으로 동작합니다.");
}

function detailview_group(seq) {
    location.href = "/manage/groups?mode=modify&seq=" + seq;
}

function detailview_retreat(seq) {
    location.href = "/staff/retreat?mode=modify&seq=" + seq;
}

function detailview_expenses(seq) {
    location.href = "/staff/expenses?mode=modify&seq=" + seq;
}

function detailview_income(seq) {
    if (seq == 9999999) {
        alert('수양회비 세부 내용은 [등록확인]메뉴를 확인바랍니다.');
    }
    else {
        location.href = "/staff/income?mode=modify&seq=" + seq;
    }
        
}

function detailview_dues(seq) {
    location.href = "/staff/retreatdues?mode=modify&seq=" + seq;
}

function detailview_items(seq) {
    var _page_code_type;
    _page_code_type = $("#ContentPlaceHolder1_ddl_code_type").val().trim();

    location.href = "/staff/items?mode=modify&seq=" + seq + "&ctype=" + _page_code_type;
}

function detailview_member(id) {
    location.href = "/manage/members?mode=modify&id=" + id;
}

function modify_group() {
    var _seq;
    _seq = $("#ContentPlaceHolder1_hdSeq").val().trim();

    location.href = "/manage/groups?mode=modify&seq=" + _seq;
}

function modify_retreat() {
    var _seq;
    _seq = $("#ContentPlaceHolder1_hdSeq").val().trim();

    location.href = "/staff/retreat?mode=modify&seq=" + _seq;
}

function modify_retreatdues() {
    var _seq;
    _seq = $("#ContentPlaceHolder1_hdSeq").val().trim();

    location.href = "/staff/retreatdues?mode=modify&seq=" + _seq;
}

function modify_expenses() {
    var _seq;
    _seq = $("#ContentPlaceHolder1_hdSeq").val().trim();

    location.href = "/staff/expenses?mode=modify&seq=" + _seq;
}

function modify_income() {
    var _seq;
    _seq = $("#ContentPlaceHolder1_hdSeq").val().trim();

    location.href = "/staff/income?mode=modify&seq=" + _seq;
}

function modify_member() {
    var _id;
    _id = $("#ContentPlaceHolder1_hdID").val().trim();

    location.href = "/manage/members?mode=modify&id=" + _id;
}

function uConfirmDel_group() {
    if (confirm("정말로 삭제하시겠습니까??")) 
        return true;
    else
        return false;
}

function uConfirmDel_retreat() {
    if (confirm("정말로 삭제하시겠습니까??"))
        return true;
    else
        return false;
}

function uConfirmDel_retreatdues() {
    if (confirm("정말로 삭제하시겠습니까??"))
        return true;
    else
        return false;
}

function uConfirmDel_expenses() {
    if (confirm("정말로 삭제하시겠습니까??"))
        return true;
    else
        return false;
}

function uConfirmDel_income() {
    if (confirm("정말로 삭제하시겠습니까??"))
        return true;
    else
        return false;
}

function uConfirm_group() {
    var _belong;
    var _manager;
    var _use_yn;
    _belong = $("#ContentPlaceHolder1_txtBelong").val().trim();
    _manager = $("#ContentPlaceHolder1_txtManager").val().trim();
    _use_yn = $("#ContentPlaceHolder1_ddl_use_yn").val().trim();

    if (_belong == "") {
        alert("요회명을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtBelong").focus();
        return false;
    }
    else if (_manager == "") {
        alert("요회목자를 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtManager").focus();
        return false;
    }
    else
    {   
        $("#ContentPlaceHolder1_hdBelong").val(_belong);
        $("#ContentPlaceHolder1_hdManager").val(_manager);
        $("#ContentPlaceHolder1_hdUseYN").val(_use_yn);
        return true;
    }
        
}

var _filesize1;

function attatch_file_init() {

    try {

        $("#ContentPlaceHolder1_fileAddAttachment_01").bind("change", function () {
            _filesize1 = this.files[0].size;
        });

    } catch (e) {
        _filesize1 = 1;
    }
}

function attatch_file_expenses_init() {
    try {

        $("#ContentPlaceHolder1_imgUpload").bind("change", function () {
            _filesize1 = this.files[0].size;
        });

    } catch (e) {
        _filesize1 = 1;
    }
}

function getFileType(filenm) {

    var _split;
    var _split_len;

    if (filenm != "") {
        _split = filenm.split(".");
        _split_len = _split.length;
        if ((_split_len - 1) > 0) {
            return _split[_split_len - 1].toLowerCase();
        }
        else { return ""; }
    }
    else { return ""; }
}

function uConfirm_retreat() {

    var _retreat_name;
    var _retreat_place;
    var _retreat_sdt;
    var _retreat_edt;
    var _retreat_desc;
    var _retreat_bank;
    var _retreat_yn;

    var _file1;
    var _filetype1;
    var _file_max_size;

    _file1 = "";
    _filetype1 = "";
    _file_max_size = 1 * 1024 * 1024; //1MB

    try {
        _file1 = $("#ContentPlaceHolder1_fileAddAttachment_01").val().trim();
        _filetype1 = getFileType(_file1);

    } catch (e) {
        
    }
    
    _retreat_name = $("#ContentPlaceHolder1_txtRetreatName").val().trim();
    _retreat_place = $("#ContentPlaceHolder1_txtRetreatPlace").val().trim();
    _retreat_sdt = $("#ContentPlaceHolder1_txtRetreatSDT").val().trim();
    _retreat_edt = $("#ContentPlaceHolder1_txtRetreatEDT").val().trim();
    _retreat_desc = $("#ContentPlaceHolder1_txtRetreatDesc").val().trim();
    _retreat_bank = $("#ContentPlaceHolder1_txtRetreatBankNo").val().trim();
    _retreat_yn = $("#ContentPlaceHolder1_ddl_retreat_status").val();

    if (_retreat_name == "") {
        alert("수양회명을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatName").focus();
        return false;
    }
    else if (_retreat_place == "") {
        alert("수양회 장소를 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatPlace").focus();
        return false;
    }
    else if (_retreat_sdt == "") {
        alert("시작일을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatSDT").focus();
        return false;
    }
    else if (_retreat_edt == "") {
        alert("종료일을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDesc").focus();
        return false;
    }
    else if (_filetype1 != ""
                && _filetype1 != "pdf"
                && _filetype1 != "jpg"
                && _filetype1 != "png"
                && _filetype1 != "gif"
                && _filetype1 != "jpeg") {
        alert("첨부파일은 pdf파일이나 이미지파일(jpg, gif, png)만 업로드 할 수 있습니다.");
        return false;
    }
    else if (_filesize1 >= _file_max_size) {
        alert("첨부파일 용량은 1MB이하만 가능합니다.");
        return false;
    }
    else {
        $("#ContentPlaceHolder1_hdRetreatName").val(_retreat_name);
        $("#ContentPlaceHolder1_hdRetreatPlace").val(_retreat_place);
        $("#ContentPlaceHolder1_hdRetreatSDT").val(_retreat_sdt);
        $("#ContentPlaceHolder1_hdRetreatEDT").val(_retreat_edt);
        $("#ContentPlaceHolder1_hdRetreatDesc").val(_retreat_desc);
        $("#ContentPlaceHolder1_hdRetreatBankNo").val(_retreat_bank);
        $("#ContentPlaceHolder1_hdRetreatYN").val(_retreat_yn);

        //alert($("#ContentPlaceHolder1_hdRetreatNM").val());

        return true;
    }

}

function uConfirm_income() {

    var _retreat;
    var _cash_item_code;
    var _expenses_item;
    var _expenses;
    var _expenses_dt;
    var _expenses_item_desc;

    var _file1;
    var _filetype1;
    var _file_max_size;

    _file1 = "";
    _filetype1 = "";
    _file_max_size = 0.5 * 1024 * 1024; //512KB

    try {
        _file1 = $("#ContentPlaceHolder1_imgUpload").val().trim();
        _filetype1 = getFileType(_file1);

    } catch (e) {

    }

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val().trim();
    _cash_item_code = $("#ContentPlaceHolder1_ddl_cash_item").val().trim();
    _expenses_item = $("#ContentPlaceHolder1_txtPaymentNM").val().trim();
    _expenses_dt = $("#ContentPlaceHolder1_txtPaymentDT").val().trim();
    _expenses = $("#ContentPlaceHolder1_txtPayment").val().trim();
    _expenses_item_desc = $("#ContentPlaceHolder1_txtPaymentDesc").val().trim();

    if (_cash_item_code == "-1") {
        alert("수입항목을 선택하지 않았습니다.");
        $("#ContentPlaceHolder1_ddl_cash_item").focus();
        return false;
    }
    else if (_expenses_item == "") {
        alert("수입내용을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDuesNM").focus();
        return false;
    }
    else if (_expenses == "" || _expenses == "0") {
        alert("수입금액을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtPayment").focus();
        return false;
    }
    else if (_expenses_dt == "") {
        alert("수입일자를 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDues").focus();
        return false;
    }
    else if (_filetype1 != ""
            && _filetype1 != "jpg"
            && _filetype1 != "png"
            && _filetype1 != "gif"
            && _filetype1 != "jpeg") {
        alert("이미지파일(jpg, gif, png)만 업로드 할 수 있습니다.");
        return false;
    }
        //else if (_filesize1 >= _file_max_size) {
        //    alert("첨부파일 용량은 512KB 이하만 가능합니다.");
        //    return false;
        //}
    else {
        $("#ContentPlaceHolder1_hdRetreat").val(_retreat);
        $("#ContentPlaceHolder1_hdCashCode").val(_cash_item_code);
        $("#ContentPlaceHolder1_hdExpensesNM").val(_expenses_item);
        $("#ContentPlaceHolder1_hdExpenses").val(_expenses);
        $("#ContentPlaceHolder1_hdExpensesDT").val(_expenses_dt);
        $("#ContentPlaceHolder1_hdExpensesDesc").val(_expenses_item_desc);

        //alert(_retreat + " / " + _cash_item_code + " / " + _expenses_item + " / " + _expenses + " / " + _expenses_dt + " / " + _expenses_item_desc )

        return true;
    }

}

function uConfirm_expenses() {

    var _retreat;
    var _cash_item_code;
    var _expenses_item;
    var _expenses;
    var _expenses_dt;
    var _expenses_item_desc;

    var _file1;
    var _filetype1;
    var _file_max_size;

    _file1 = "";
    _filetype1 = "";
    _file_max_size = 0.5 * 1024 * 1024; //512KB

    try {
        _file1 = $("#ContentPlaceHolder1_imgUpload").val().trim();
        _filetype1 = getFileType(_file1);

    } catch (e) {

    }

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val().trim();
    _cash_item_code = $("#ContentPlaceHolder1_ddl_cash_item").val().trim();
    _expenses_item = $("#ContentPlaceHolder1_txtPaymentNM").val().trim();
    _expenses_dt = $("#ContentPlaceHolder1_txtPaymentDT").val().trim();
    _expenses = $("#ContentPlaceHolder1_txtPayment").val().trim();
    _expenses_item_desc = $("#ContentPlaceHolder1_txtPaymentDesc").val().trim();

    if (_cash_item_code == "-1") {
        alert("지출항목을 선택하지 않았습니다.");
        $("#ContentPlaceHolder1_ddl_cash_item").focus();
        return false;
    }
    else if (_expenses_item == "") {
        alert("지출내용을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDuesNM").focus();
        return false;
    }
    else if (_expenses_dt == "") {
        alert("지출일자를 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDues").focus();
        return false;
    }
    else if (_filetype1 != ""
            && _filetype1 != "jpg"
            && _filetype1 != "png"
            && _filetype1 != "gif"
            && _filetype1 != "jpeg") {
        alert("이미지파일(jpg, gif, png)만 업로드 할 수 있습니다.");
        return false;
    }
    //else if (_filesize1 >= _file_max_size) {
    //    alert("첨부파일 용량은 512KB 이하만 가능합니다.");
    //    return false;
    //}
    else {
        $("#ContentPlaceHolder1_hdRetreat").val(_retreat);
        $("#ContentPlaceHolder1_hdCashCode").val(_cash_item_code);
        $("#ContentPlaceHolder1_hdExpensesNM").val(_expenses_item);
        $("#ContentPlaceHolder1_hdExpenses").val(_expenses);
        $("#ContentPlaceHolder1_hdExpensesDT").val(_expenses_dt);
        $("#ContentPlaceHolder1_hdExpensesDesc").val(_expenses_item_desc);

        //alert(_retreat + " / " + _cash_item_code + " / " + _expenses_item + " / " + _expenses + " / " + _expenses_dt + " / " + _expenses_item_desc )

        return true;
    }

}

function uConfirm_retreatdues() {

    var _retreat;
    var _retreat_dues_nm;
    var _retreat_dues;
    var _retreat_dues_desc;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val().trim();
    _retreat_dues_nm = $("#ContentPlaceHolder1_txtRetreatDuesNM").val().trim();
    _retreat_dues = $("#ContentPlaceHolder1_txtRetreatDues").val().trim();
    _retreat_dues_desc = $("#ContentPlaceHolder1_txtRetreatDuesDesc").val().trim();

    if (_retreat_dues_nm == "") {
        alert("회비구분명을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDuesNM").focus();
        return false;
    }
    else if (_retreat_dues == "") {
        alert("회비를 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtRetreatDues").focus();
        return false;
    }
    else {
        $("#ContentPlaceHolder1_hdRetreat").val(_retreat);
        $("#ContentPlaceHolder1_hdRetreatDuesNM").val(_retreat_dues_nm);
        $("#ContentPlaceHolder1_hdRetreatDues").val(_retreat_dues);
        $("#ContentPlaceHolder1_hdRetreatDuesDesc").val(_retreat_dues_desc);

        return true;
    }

}

function uConfirm_item() {

    var _retreat;
    var _cash_type;
    var _item_nm;
    var _item_desc;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val().trim();
    _cash_type = $("#ContentPlaceHolder1_ddl_code_type_write").val().trim();
    _item_nm = $("#ContentPlaceHolder1_txtCodeNM").val().trim();
    _item_desc = $("#ContentPlaceHolder1_txtItemDesc").val().trim();

    if (_item_nm == "") {
        alert("코드명을 입력하지 않았습니다.");
        $("#ContentPlaceHolder1_txtCodeNM").focus();
        return false;
    }
    else {
        $("#ContentPlaceHolder1_hdRetreat").val(_retreat);
        $("#ContentPlaceHolder1_hdCashType").val(_cash_type);
        $("#ContentPlaceHolder1_hdCodeNM").val(_item_nm);
        $("#ContentPlaceHolder1_hdCodeDesc").val(_item_desc);

        return true;
    }

}

function go_item_list() {
    //var _page_code_type;
    //_page_code_type = $("#ContentPlaceHolder1_ddl_code_type").val().trim();
    //location.href = "/staff/items?ctype=" + _page_code_type;
    location.href = "/staff/items";
}

function go_item_new() {
    var _page_code_type;
    _page_code_type = $("#ContentPlaceHolder1_ddl_code_type").val().trim();

    location.href = "/staff/items?mode=write&ctype=" + _page_code_type;
        
}

function uConfirm_member() {

    var _kor_nm;
    var _email;
    var _belong;
    var _type;
    var _status;
    var _belong_nm;
    var _type_nm;
    var _status_nm;
    var _regExp;

    _kor_nm = $("#ContentPlaceHolder1_txtKorNm").val().trim();
    _email = $("#ContentPlaceHolder1_txtEmail").val().trim();
    _belong = $("#ContentPlaceHolder1_ddl_group").val();
    _type = $("#ContentPlaceHolder1_ddl_type").val();
    _status = $("#ContentPlaceHolder1_ddl_status").val();

    _belong_nm = $("#ContentPlaceHolder1_ddl_group option:selected").text();
    _type_nm = $("#ContentPlaceHolder1_ddl_type option:selected").text();
    _status_nm = $("#ContentPlaceHolder1_ddl_status option:selected").text();

    //이메일 형식
    _regExp = /^([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\.[0-9a-zA-Z_-]+){1,2}$/;

    if (_kor_nm.trim() == "") {
        alert("성명을 입력하십시오.");
        $("#ContentPlaceHolder1_txtKorNm").focus();
        return false;
    }
    else if (_email.trim() == "") {
        alert("이메일을 입력하십시오.");
        $("#ContentPlaceHolder1_txtEmail").focus();
        return false;
    }
    else if (!_regExp.test(_email.trim())) {
        alert("이메일 형식이 잘못되었습니다.");
        $("#ContentPlaceHolder1_txtEmail").val("");
        $("#ContentPlaceHolder1_txtEmail").focus();
        return false;
    }
    else {
        $("#ContentPlaceHolder1_hdBelong").val(_belong);
        $("#ContentPlaceHolder1_hdUserType").val(_type);
        $("#ContentPlaceHolder1_hdStatus").val(_status);

        $("#ContentPlaceHolder1_hdKorNm").val(_kor_nm);
        $("#ContentPlaceHolder1_hdEmail").val(_email);

        $("#ContentPlaceHolder1_hdBelongNm").val(_belong_nm);
        $("#ContentPlaceHolder1_hdUserTypeNm").val(_type_nm);
        $("#ContentPlaceHolder1_hdStatusNm").val(_status_nm);

        return true;
    }

}

function uConfirm_modi01() {

    var _kor_nm;
    var _email;
    var _belong;
    var _belong_nm;
    var _regExp;

    _kor_nm = $("#ContentPlaceHolder1_txtKorNm").val().trim();
    _email = $("#ContentPlaceHolder1_txtEmail").val().trim();
    _belong = $("#ContentPlaceHolder1_ddl_group").val();
    _belong_nm = $("#ContentPlaceHolder1_ddl_group option:selected").text();;

    //이메일 형식
    _regExp = /^([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\.[0-9a-zA-Z_-]+){1,2}$/;

    if (_kor_nm.trim() == "") {
        alert("성명을 입력하십시오.");
        $("#ContentPlaceHolder1_txtKorNm").focus();
        return false;
    }
    else if (_email.trim() == "") {
        alert("이메일을 입력하십시오.");
        $("#ContentPlaceHolder1_txtEmail").focus();
        return false;
    }
    else if (!_regExp.test(_email.trim())) {
        alert("이메일 형식이 잘못되었습니다.");
        $("#ContentPlaceHolder1_txtEmail").val("");
        $("#ContentPlaceHolder1_txtEmail").focus();
        return false;
    }
    else {
        $("#ContentPlaceHolder1_hdBelong").val(_belong);
        $("#ContentPlaceHolder1_hdKorNm").val(_kor_nm);
        $("#ContentPlaceHolder1_hdEmail").val(_email);
        $("#ContentPlaceHolder1_hdBelongNm").val(_belong_nm);

        return true;
    }

}

function setMouseOverColor(element) {
    oldgridSelectedColor = element.style.color;
    element.style.color = 'blue';
    element.style.cursor = 'pointer';
}
function setMouseOutColor(element) {
    element.style.color = oldgridSelectedColor;
    element.style.textDecoration = 'none';
}

function idCheck() {

    var _c_id;
    var _c_patt;

    //아이디 형식 - 영문자 또는 영문자 숫자 조합 또는 숫자, 최소5자에서 최대 20자
    _c_patt = /^[A-za-z0-9]{2,20}$/g;

    _c_id = $("#ContentPlaceHolder1_txtJoinID").val();

    if (_c_id.trim() == "") {

        alert("아이디를 입력 후 확인버튼을 클릭하십시오.");
        $("#ContentPlaceHolder1_txtJoinID").focus();
        $("#txtChkResult").val("");
        $("#txtidOK").hide();
        $("#txtidNO").hide();
        return false;
    }
    else if (!_c_patt.test(_c_id.trim())) {

        alert("아이디 형식이 잘못되었습니다. (영문자/숫자, 2자~20자)");
        $("#ContentPlaceHolder1_txtJoinID").val("");
        $("#ContentPlaceHolder1_txtJoinID").focus();
        $("#txtChkResult").val("");
        $("#txtidOK").hide();
        $("#txtidNO").hide();
        return false;
    }
    else {
        return true;
    }
}

function chkResult() {

    var _rslt;
    _rslt = $("#txtChkResult").val();

    if (_rslt.trim() == "OK") {
        $("#txtidOK").show();
        $("#txtidNO").hide();
    }
    else if (_rslt.trim() == "NO") {
        $("#txtidOK").hide();
        $("#txtidNO").show();
    }
    else {
        $("#txtidOK").hide();
        $("#txtidNO").hide();
    }
}

function idcheckinit() {
    $("#txtChkResult").val("");
    $("#txtidOK").hide();
    $("#txtidNO").hide();
    return true;
}

function uJoinConfirm(stp) {
    if (stp == "step01") {
        var chk01;
        var chk02;

        chk01 = $("#ContentPlaceHolder1_chkAgree01").is(":checked");
        chk02 = $("#ContentPlaceHolder1_chkAgree02").is(":checked");

        if (chk01 == false) {
            alert("이용약관에 동의하여 주십시오.");
            return false;
        }
        else if (chk02 == false) {
            alert("개인정보 수집 및 이용에 동의하여 주십시오.");
            return false;
        }
        else {
            return true;
        }
    }
    else if (stp == "step02") {
        var joinid;
        var joinpwd;
        var joinpwd2;
        var joinconfirm01;
        var joinconfirm02;
        var joinnm;
        var joinemail;
        var joinbelong;
        var joinbelong_nm;
        var jointype;

        var _pattID;
        var _regExp;
        var _patt;

        //아이디 형식 - 영문자 또는 영문자 숫자 조합 또는 숫자, 최소2자에서 최대 20자
        _pattID = /^[A-za-z0-9]{2,20}$/g;

        //이메일 형식
        _regExp = /^([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\.[0-9a-zA-Z_-]+){1,2}$/;

        //특수문자 포함 (7자 이상)
        _patt = /^.*(?=^.{7,100}$)(?=.*[!@#$%^&*+=()]).*$/;

        joinid = $("#ContentPlaceHolder1_txtJoinID").val();
        idchkresult = $("#txtChkResult").val();
        joinpwd = $("#ContentPlaceHolder1_txtJoinPWD").val();
        joinpwd2 = $("#ContentPlaceHolder1_txtJoinPWD2").val();
        joinconfirm01 = $("#ContentPlaceHolder1_txtConfirm01").val();
        joinconfirm02 = $("#ContentPlaceHolder1_txtConfirm02").val();
        joinnm = $("#ContentPlaceHolder1_txtJoinNM").val();
        joinemail = $("#ContentPlaceHolder1_txtJoinEMAIL").val();
        joinbelong = $("#ContentPlaceHolder1_ddl_group").val();
        joinbelong_nm = $("#ContentPlaceHolder1_ddl_group option:selected").text();
        jointype = $("#ContentPlaceHolder1_ddl_type").val();

        if (joinid.trim() == "") {

            alert("아이디를 입력하십시오.");
            $("#ContentPlaceHolder1_txtJoinID").focus();
            return false;
        }
        else if (!_pattID.test(joinid.trim())) {

            alert("아이디 형식이 잘못되었습니다. (영문자/숫자, 2자~20자)");
            $("#ContentPlaceHolder1_txtJoinID").val("");
            $("#ContentPlaceHolder1_txtJoinID").focus();
            return false;
        }
        else if (idchkresult.trim() == "") {
            alert("'아이디중복확인' 버튼을 클릭하십시오.");
            $("#txtChkResult").focus();
            $("#txtidOK").hide();
            $("#txtidNO").hide();
            return false;
        }
        else if (idchkresult.trim() == "NO") {
            alert("다른 아이디를 입력하십시오.");
            $("#txtChkResult").val("");
            $("#ContentPlaceHolder1_txtJoinID").focus();
            return false;
        }
        else if (joinpwd.trim() == "") {

            alert("비밀번호를 입력하십시오.");
            $("#ContentPlaceHolder1_txtJoinPWD").focus();
            return false;
        }
        else if (!_patt.test(joinpwd.trim())) {
            alert("비밀번호의 길이는 7자 이상이어야 하며 특수문자 1자 이상 포함되어 있어야 합니다.");
            $("#ContentPlaceHolder1_txtJoinPWD").val("");
            $("#ContentPlaceHolder1_txtJoinPWD").focus();
            return false;
        }
        else if (joinpwd2.trim() == "") {
            alert("비밀번호확인을 입력하십시오.");
            $("#ContentPlaceHolder1_txtJoinPWD2").focus();
            return false;
        }
        else if (joinpwd.trim() != joinpwd2.trim()) {
            alert("비밀번호와 비밀번호확인이 서로 다릅니다.");
            $("#ContentPlaceHolder1_txtJoinPWD2").focus();
            return false;
        }
        else if (joinconfirm01.trim() == "") {
            alert("본인 확인 질문을 입력하십시오.");
            $("#ContentPlaceHolder1_txtConfirm01").focus();
            return false;
        }
        else if (joinconfirm02.trim() == "") {
            alert("본인 확인 답변을 입력하십시오.");
            $("#ContentPlaceHolder1_txtConfirm02").focus();
            return false;
        }
        
        else if (joinnm.trim() == "") {
            alert("이름을 입력하십시오.");
            $("#ContentPlaceHolder1_txtJoinNM").focus();
            return false;
        }
        else if (joinemail.trim() == "") {
            alert("이메일을 입력하십시오.");
            $("#ContentPlaceHolder1_txtJoinEMAIL").focus();
            return false;
        }
        else if (!_regExp.test(joinemail.trim())) {
            alert("이메일 형식이 잘못되었습니다.");
            $("#ContentPlaceHolder1_txtJoinEMAIL").val("");
            $("#ContentPlaceHolder1_txtJoinEMAIL").focus();
            return false;
        }
        else if (joinbelong.trim() == "-1") {
            alert("요회를 선택하십시오.");
            $("#ContentPlaceHolder1_ddl_group").focus();
            return false;
        }
        else if (jointype.trim() == "-1") {
            alert("회원구분을 선택하십시오.");
            $("#ContentPlaceHolder1_ddl_type").focus();
            return false;
        }
        else {
            $("#ContentPlaceHolder1_hdBelongCode").val(joinbelong);
            $("#ContentPlaceHolder1_hdUserTypeCode").val(jointype);
            $("#ContentPlaceHolder1_hdBelongName").val(joinbelong_nm);
            
            return true;
        }
    }
    else {
        return false;
    }
}


function viewpassinit() {
    $("#btnpassinitview").hide();
    $("#btnpassinitclose").show();
    $("#tbpassinit").slideDown();
    
}

function viewpassinitclose() {
    $("#btnpassinitview").show();
    $("#btnpassinitclose").hide();
    $("#tbpassinit").slideUp();

    $("#ContentPlaceHolder1_txtNewPWD").val("");
    $("#ContentPlaceHolder1_txtNewPWD2").val("");
}

function ConfirmPassInit() {
    var txt01;
    var txt02;

    txt01 = $("#ContentPlaceHolder1_txtNewPWD").val().trim();
    txt02 = $("#ContentPlaceHolder1_txtNewPWD2").val().trim();

    if (txt01 == "") {
        alert("변경(초기화) 할 비밀번호를 입력하세요!!");
        $("#ContentPlaceHolder1_txtNewPWD").focus();
        return false;
    }
    else if (txt02 == "") {
        alert("비밀번호 확인을 입력하세요!!");
        $("#ContentPlaceHolder1_txtNewPWD2").focus();
        return false;
    }
    else if (txt01 != txt02) {
        alert("변경할 비밀번호가 서로 다릅니다!!");
        $("#ContentPlaceHolder1_txtNewPWD").val("");
        $("#ContentPlaceHolder1_txtNewPWD2").val("");
        $("#ContentPlaceHolder1_txtNewPWD").focus();
        return false;
    }
    else {
        if (confirm("입력한 비밀번호로 초기화 하시겠습니까?")) {
            return true;
        }
        else {
            return false;
        }
    }
}


function idsaveinit() {    
    
    var key = getCookie("idkey");

    $("#ContentPlaceHolder1_txtLoginID").val(key);

    if ($("#ContentPlaceHolder1_txtLoginID").val().trim() != "") {
        $("#checkId").attr("checked", true); // ID 저장하기를 체크 상태로 두기.
    }

    $("#checkId").change(function () { // 체크박스에 변화가 있다면,
        
        if ($("#checkId").is(":checked")) { // ID 저장하기 체크했을 때,
            setCookie("idkey", $("#ContentPlaceHolder1_txtLoginID").val(), 180); // 180일 동안 쿠키 보관
        } else { // ID 저장하기 체크 해제 시,
            deleteCookie("idkey");
        }
    });

    // ID 저장하기를 체크한 상태에서 ID를 입력하는 경우, 이럴 때도 쿠키 저장.
    $("#ContentPlaceHolder1_txtLoginID").keyup(function () { // ID 입력 칸에 ID를 입력할 때,
        if ($("#checkId").is(":checked")) { // ID 저장하기를 체크한 상태라면,
            setCookie("idkey", $("#ContentPlaceHolder1_txtLoginID").val(), 180); // 180일 동안 쿠키 보관
        }
    });

}

// 쿠키 저장하기 
// setCookie => saveid함수에서 넘겨준 시간이 현재시간과 비교해서 쿠키를 생성하고 지워주는 역할
function setCookie(cookieName, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var cookieValue = escape(value)
            + ((exdays == null) ? "" : "; expires=" + exdate.toGMTString());
    document.cookie = cookieName + "=" + cookieValue;
}

// 쿠키 삭제
function deleteCookie(cookieName) {
    var expireDate = new Date();
    expireDate.setDate(expireDate.getDate() - 1);
    document.cookie = cookieName + "= " + "; expires="
            + expireDate.toGMTString();
}

// 쿠키 가져오기
function getCookie(cookieName) {
    cookieName = cookieName + '=';
    var cookieData = document.cookie;
    var start = cookieData.indexOf(cookieName);
    var cookieValue = '';
    if (start != -1) { // 쿠키가 존재하면
        start += cookieName.length;
        var end = cookieData.indexOf(';', start);
        if (end == -1) // 쿠키 값의 마지막 위치 인덱스 번호 설정 
            end = cookieData.length;
        console.log("end위치  : " + end);
        cookieValue = cookieData.substring(start, end);
    }
    return unescape(cookieValue);
}

function uFindidConfirm() {

    var _name;
    var _email;

    _name = $("#ContentPlaceHolder1_txtNAME").val();
    _email = $("#ContentPlaceHolder1_txtEMAIL").val();

    //이메일 형식
    _regExp = /^([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\.[0-9a-zA-Z_-]+){1,2}$/;

    if (_name.trim() == "") {
        alert("이름을 입력하십시오.");
        $("#ContentPlaceHolder1_txtNAME").focus();
        return false;
    }
    else if (_email.trim() == "") {
        alert("이메일을 입력하십시오.");
        $("#ContentPlaceHolder1_txtEMAIL").focus();
        return false;
    }
    else if (!_regExp.test(_email.trim())) {
        alert("이메일 형식이 잘못되었습니다.");
        $("#ContentPlaceHolder1_txtEMAIL").val("");
        $("#ContentPlaceHolder1_txtEMAIL").focus();
        return false;
    }
    else {

        return true;
    }

}

function findidcancel() {
    location.replace("/member/login");
}

function gomain() {
    location.href = "/";
}

function uModiPwdQuestion() {
    var txt01;
    var txt02;
    var pwd;

    pwd = $("#ContentPlaceHolder1_txtMyPassword").val().trim();
    txt01 = $("#ContentPlaceHolder1_txtNewQuestion").val().trim();
    txt02 = $("#ContentPlaceHolder1_txtAnswer").val().trim();

    if (pwd == "") {
        alert("본인 계정의 비밀번호를 입력하세요!!");
        $("#ContentPlaceHolder1_txtMyPassword").focus();
        return false;
    }
    else if (txt01 == "") {
        alert("본인확인용 질문을 입력하세요!!");
        $("#ContentPlaceHolder1_txtNewQuestion").focus();
        return false;
    }
    else if (txt02 == "") {
        alert("본인확인용 질문의 답변을 입력하세요!!");
        $("#ContentPlaceHolder1_txtAnswer").focus();
        return false;
    }
    else {
        if (confirm("본인확인용 질문 및 답변을 변경하시겠습니까?")) {
            return true;
        }
        else {
            return false;
        }
    }
}

function set_table_usermanage() {

    var _tr_contents;
    var _usertype_contents;
    var _duestype_contents;
    var _regitype_contents;

    var _members;
    var _members_count;
    var _members_row;
    var _members_item;

    var _duestypes;
    var _duestypes_count;
    var _duestypes_row;
    var _duestypes_item;
    var _dues_amount;
    var _delete_button;

    var _user_role;

    _members_count = Number($("#ContentPlaceHolder1_hdGroupMembersCount").val());
    _usertypes_count = Number($("#ContentPlaceHolder1_hdUsertypesCount").val());
    _duestypes_count= Number($("#ContentPlaceHolder1_hdDuestypesCount").val());

    _user_role = $("#ContentPlaceHolder1_hdUserRole").val();
    //alert(_user_role);

    _tr_contents = "";
    _usertype_contents = "";
    _duestype_contents = "";
    _regitype_contents = "";

    if (_members_count > 0) {

        _members = $("#ContentPlaceHolder1_hdGroupMembers").val();
        _members_row = _members.split("†");

        for (var i = 0; i < _members_row.length; i++) {

            _members_item = _members_row[i].split("‡");

            //_members_item[7] : manager_confirm, _members_item[10] : manager_confirm_first
            if ((_members_item[7] == 'Y' || _members_item[10] == 'Y') && _user_role == 'user') 
                _delete_button = "<input type='button' class='site-button site-button-dark site-button-sm site-grid-delete-button' value='행삭제' disabled onclick=\"remove_tr(this);\" />";
            else
                _delete_button = "<input type='button' class='site-button site-button-dark site-button-sm site-grid-delete-button' value='행삭제' onclick=\"remove_tr(this);\" />";
            
            _tr_contents = "<tr class='" + _members_item[9] + "'>"

            /////// 성명
            + "<td class='nowrap'>"
            + "<input type='text' class='ui-input ui-input-sm' value='" + _members_item[0] + "' style='width:76px;' />" //_members_item[0] : 성명
            + "</td>"

            /////// 사용자구분코드
            + "<td class='nowrap'>";
            _usertype_contents = "<select name='ddl_usertype' class='ui-select ui-select-sm' style='width:auto;'>";

            if (_members_item[2] == '1') //_members_item[2] : 사용자구분코드
                _usertype_contents = _usertype_contents + "<option selected='selected' value='1'>목자</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='1'>목자</option>";

            if (_members_item[2] == '2')
                _usertype_contents = _usertype_contents + "<option selected='selected' value='2'>목동</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='2'>목동</option>";

            if (_members_item[2] == '3')
                _usertype_contents = _usertype_contents + "<option selected='selected' value='3'>양</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='3'>양</option>";

            _usertype_contents = _usertype_contents + "</select>";

            _tr_contents = _tr_contents + _usertype_contents;
            _tr_contents = _tr_contents + "</td>"


            /////// 회비구분코드
            + "<td class='nowrap'>";
            if (_duestypes_count > 0) {
                _duestypes = $("#ContentPlaceHolder1_hdDuestypes").val();
                _duestypes_row = _duestypes.split("†");
                _duestype_contents = "<select name='ddl_duestype' class='ui-select ui-select-sm' style='width:auto;' onchange='updateUsermanageRegistStatus(this);'>";

                for (var j = 0; j < _duestypes_row.length; j++) {
                    _duestypes_item = _duestypes_row[j].split("‡");
                    _dues_amount = _duestypes_item.length > 2 ? _duestypes_item[2] : "";

                    if (_members_item[3] == _duestypes_item[0]) //_members_item[3] : 회비구분코드
                        _duestype_contents = _duestype_contents + "<option selected='selected' data-dues='" + _dues_amount + "' value='" + _duestypes_item[0] + "'>" + _duestypes_item[1] + "</option>";
                    else
                        _duestype_contents = _duestype_contents + "<option data-dues='" + _dues_amount + "' value='" + _duestypes_item[0] + "'>" + _duestypes_item[1] + "</option>";
                }

                _duestype_contents = _duestype_contents + "</select>";
            }

            _tr_contents =  _tr_contents + _duestype_contents;
            _tr_contents = _tr_contents + "</td>"

            /////// 납부비용
            + "<td class='nowrap'>"
            + "<input type='text' class='ui-input ui-input-sm' value='" + _members_item[4] + "' style='width:82px;' onkeyup='inputNumberFormat(this); updateUsermanageRegistStatus(this);' />" //_members_item[4] : 납부비용
            + "</td>"


            /////// 납부방법코드
            + "<td class='nowrap'>";
            _regitype_contents = "<select name='ddl_regitype' class='ui-select ui-select-sm' style='width:auto;'>";

            if (_members_item[5] == '1') //_members_item[5] : 납부방법코드
                _regitype_contents = _regitype_contents + "<option selected='selected' value='1'>계좌이체</option>";
            else
                _regitype_contents = _regitype_contents + "<option value='1'>계좌이체</option>";

            if (_members_item[5] == '2')
                _regitype_contents = _regitype_contents + "<option selected='selected' value='2'>현금납부</option>";
            else
                _regitype_contents = _regitype_contents + "<option value='2'>현금납부</option>";

            _regitype_contents = _regitype_contents + "</select>";

            _tr_contents = _tr_contents + _regitype_contents;
            _tr_contents = _tr_contents + "</td>"

            /////// 비고
            + "<td class='nowrap'>"
            + "<input type='text' class='ui-input ui-input-sm' value='" + _members_item[6] + "' style='min-width:76px;' />" //_members_item[6] : 비고
            + "</td>"

            /////// 실무자확인
            + "<td class='nowrap'>"
            + _members_item[7] //_members_item[7] : 실무자확인
            + "</td>"

            /////// 참석여부구분
            + "<td class='nowrap'>";
            _usertype_contents = "<select name='ddl_attend' class='ui-select ui-select-sm' style='width:auto;'>";

            if (_members_item[10] == 'N') //_members_item[10] : 참석여부구분
                _usertype_contents = _usertype_contents + "<option selected='selected' value='N'>미참석</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='N'>미참석</option>";

            if (_members_item[10] == 'P')
                _usertype_contents = _usertype_contents + "<option selected='selected' value='P'>부분참석</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='P'>부분참석</option>";

            if (_members_item[10] == 'A')
                _usertype_contents = _usertype_contents + "<option selected='selected' value='A'>완전참석</option>";
            else
                _usertype_contents = _usertype_contents + "<option value='A'>완전참석</option>";

            _usertype_contents = _usertype_contents + "</select>";

            _tr_contents = _tr_contents + _usertype_contents;
            _tr_contents = _tr_contents + "</td>"


            /////// seq
            + "<td class='displaynone'>"
            + "<input type='text' class='ui-input ui-input-sm' value='" + _members_item[8] + "' />" //_members_item[8] : seq
            + "</td>"

            /////// 행삭제버튼
            + "<td class='nowrap'>"
            + _delete_button
            + "</td>"
            

            + "</tr>";

            $(_tr_contents).appendTo('#tb_member');
        }
    }
}


function comma(str) {
    str = String(str);
    return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
}

function uncomma(str) {
    str = String(str);
    return str.replace(/[^\d]+/g, '');
}

function inputNumberFormat(obj) {
    obj.value = comma(uncomma(obj.value));
}

function parseUsermanageAmount(value) {
    var normalized = String(value || "").replace(/,/g, "").replace(/[^\d.-]/g, "");
    var amount = Number(normalized);

    return isNaN(amount) ? 0 : amount;
}

function getUsermanageRegistStatus(payment, dues) {
    if (dues <= 0 || payment <= 0) {
        return { className: "table-danger", memo: "미등록" };
    }

    if (payment >= dues) {
        return { className: "table-success", memo: "완전등록" };
    }

    return { className: "table-warning", memo: "부분등록" };
}

function updateUsermanageRegistStatus(obj) {
    var $row = $(obj).closest("#tb_member tr");

    if ($row.length === 0 || $row.index() === 0) {
        return;
    }

    var $duesOption = $row.find("select[name=ddl_duestype] option:selected");
    var dues = parseUsermanageAmount($duesOption.attr("data-dues"));

    if (dues <= 0) {
        return;
    }

    var payment = parseUsermanageAmount($row.children("td").eq(3).find("input[type='text']").val());
    var status = getUsermanageRegistStatus(payment, dues);

    $row
        .removeClass("table-success table-warning table-danger bd-green-100 bd-yellow-100 bd-red-100")
        .addClass(status.className);

    $row.children("td").eq(5).find("input[type='text']").val(status.memo);
}

function inputOnlyNumberFormat(obj) {
    obj.value = onlynumber(uncomma(obj.value));
}

function onlynumber(str) {
    str = String(str);
    return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1');
}


function add_member_tr() {
    var _tr_row;
    var _tr_contents;
    var _duestype_contents;

    var _duestypes;
    var _duestypes_count;
    var _duestypes_row;
    var _duestypes_item;
    var _dues_amount;

    _duestypes_count= Number($("#ContentPlaceHolder1_hdDuestypesCount").val());
    _duestype_contents = "";

    if (_duestypes_count > 0) {
        _duestypes = $("#ContentPlaceHolder1_hdDuestypes").val();
        _duestypes_row = _duestypes.split("†");

        _duestype_contents = "<select name='ddl_duestype' class='ui-select ui-select-sm' style='width:auto;' onchange='updateUsermanageRegistStatus(this);'>";

        for (var j = 0; j < _duestypes_row.length; j++) {
            _duestypes_item = _duestypes_row[j].split("‡");
            _dues_amount = _duestypes_item.length > 2 ? _duestypes_item[2] : "";
            _duestype_contents = _duestype_contents + "<option data-dues='" + _dues_amount + "' value='" + _duestypes_item[0] + "'>" + _duestypes_item[1] + "</option>";
        }

        _duestype_contents = _duestype_contents + "</select>";
    }


    _tr_row = $("#tb_member tr").length;
    _tr_contents = "<tr>"

        //성명
        + "<td class='nowrap'>"
        + "<input type='text' class='ui-input ui-input-sm' style='width:76px;' />"
        + "</td>"

        //사용자구분
        + "<td class='nowrap'>"
        + "<select name='ddl_usertype' class='ui-select ui-select-sm' style='width:auto;'>"
        + "<option value='1'>목자</option>"
        + "<option value='2'>목동</option>"
        + "<option value='3'>양</option>"
        + "</select>"
        + "</td>"

        //회비구분
        + "<td class='nowrap'>"
        + _duestype_contents
        + "</td>"

        //납부비용
        + "<td class='nowrap'>"
        + "<input type='text' class='ui-input ui-input-sm' style='width:82px;' onkeyup='inputNumberFormat(this); updateUsermanageRegistStatus(this);' />"
        + "</td>"

        //납부방법코드
        + "<td class='nowrap'>"
        + "<select name='ddl_regitype' class='ui-select ui-select-sm' style='width:auto;'>"
        + "<option value='1'>계좌이체</option>"
        + "<option value='2'>현금납부</option>"
        + "</select>"
        + "</td>"

        //비고
        + "<td class='nowrap'>"
        + "<input type='text' class='ui-input ui-input-sm' style='min-width:76px;' />"
        + "</td>"
        
        //실무자확인
        + "<td class='nowrap'>N"        
        + "</td>"

        //참석여부
        + "<td class='nowrap'>"
        + "<select name='ddl_attend' class='ui-select ui-select-sm' style='width:auto;'>"
        + "<option value='N'>미참석</option>"
        + "<option value='P'>부분참석</option>"
        + "<option value='A'>완전참석</option>"
        + "</select>"
        + "</td>"

        //seq용 빈칸
        + "<td class='displaynone'>"
        + "<input type='text' class='ui-input ui-input-sm' />"        
        + "</td>"

        //삭제
        + "<td class='nowrap'>"
        + "<input type='button' class='site-button site-button-dark site-button-sm site-grid-delete-button' value='행삭제' onclick=\"remove_tr(this);\" />"
        + "</td>"

        

        + "</tr>";

    //alert(_duestype_contents);

    $(_tr_contents).appendTo('#tb_member');
    updateUsermanageRegistStatus($("#tb_member tr:last-child").children("td").eq(3).find("input[type='text']")[0]);
}

function remove_tr(tr) {

    tr.parentNode.parentNode.remove();
}

function confirm_member_mig() {

    if (confirm("이전 수양회 구성원을 이관하시겠습니까?")) {
        return true;
    }
    else {
        return false;
    }
}

function save_members_table() {
    var _input;
    var _usertype;
    var _duestype;
    var _regitype;
    var _attend;

    var _save_data;

    _input = $("#tb_member tr td input").length;
    _usertype = $("#tb_member tr td select[name=ddl_usertype] option:selected").length;
    _duestype = $("#tb_member tr td select[name=ddl_duestype] option:selected").length;
    _regitype = $("#tb_member tr td select[name=ddl_regitype] option:selected").length;
    _attend = $("#tb_member tr td select[name=ddl_attend] option:selected").length;

    //alert(_duestype);

    _save_data = "";

    if (_input > 0 && _duestype > 0) {
        for (var i = 0; i < _input; i++) {
            _save_data = _save_data + $("#tb_member tr td input").eq(i).val().trim() + "‡"
        }
        _save_data = _save_data + "†";

        for (var j = 0; j < _usertype; j++) {
            _save_data = _save_data + $("select[name=ddl_usertype] option:selected").eq(j).val().trim() + "‡"
        }

        _save_data = _save_data + "†";

        for (var k = 0; k < _duestype; k++) {
            _save_data = _save_data + $("select[name=ddl_duestype] option:selected").eq(k).val().trim() + "‡"
        }

        _save_data = _save_data + "†";

        for (var m = 0; m < _regitype; m++) {
            _save_data = _save_data + $("select[name=ddl_regitype] option:selected").eq(m).val().trim() + "‡"
        }

        _save_data = _save_data + "†";

        for (var n = 0; n < _attend; n++) {
            _save_data = _save_data + $("select[name=ddl_attend] option:selected").eq(n).val().trim() + "‡"
        }
    }
    else {
        _save_data = "";
    }   

    $("#ContentPlaceHolder1_hdSaveMembers").val(_save_data);

    //alert($("#ContentPlaceHolder1_hdSaveMembers").val());
    //return false;

    if (confirm("저장 하시겠습니까? \n\n- 행삭제를 한 경우, 해당 데이터는 삭제됩니다.\n- 성명이 빈칸인 행은 저장되지 않습니다.")) {
        return true;
    }
    else {
        return false;
    }
}

$.datepicker.setDefaults({
    dateFormat: 'yy-mm-dd',
    showOtherMonths: true, //빈 공간에 현재월의 앞뒤월의 날짜를 표시
    changeYear: true, //콤보박스에서 년 선택 가능
    changeMonth: true, //콤보박스에서 월 선택 가능
    prevText: '이전 달',
    nextText: '다음 달',
    monthNames: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    monthNamesShort: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    dayNames: ['일', '월', '화', '수', '목', '금', '토'],
    dayNamesShort: ['일', '월', '화', '수', '목', '금', '토'],
    dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
    showMonthAfterYear: true,
    yearSuffix: "년" //달력의 년도 부분 뒤에 붙는 텍스트
});

function selectAllChkFunc() {
    $("#ListViewTable .selectAllChk input").click();
}

function manager_confirm_select() {
    // Select deselect all
    $("#ListViewTable .selectAllChk input").click(function () {
        if ($(this).is(":checked")) {
            $("#ListViewTable .selectOneChk input").prop('checked', true);
                
        } else {
            $("#ListViewTable .selectOneChk input").prop('checked', false);
        }
    });

    // Update select all based on individual checkbox 
    $("#ListViewTable .selectOneChk input").click(function() {
        if ($(this).is(':checked')) {
            if ($("#ListViewTable .selectOneChk input:checked").length == $("#ListViewTable .selectOneChk input").length) {
                $("#ListViewTable .selectAllChk input").prop('checked', true);
            } else {
                $("#ListViewTable .selectAllChk input").prop('checked', false);
            }          
        } else {
            $("#ListViewTable .selectAllChk input").prop('checked', false);
        }
    });  
}

function manage_confirm_save() {
    if ($("#ListViewTable .selectOneChk input:checked").length == 0) {
        if (confirm("체크된 행이 하나도 없습니다. 이대로 저장하시겠습니까?")) {
            return true;
        }
        else {
            return false;
        }
    }
    else {
        if (confirm("이대로 저장하시겠습니까?")) {
            return true;
        }
        else {
            return false;
        }
    }
}


function excel_export() {

    var _retreat;
    var _group;
    var _regi_type;
    var _url;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val();
    _group = $("#ContentPlaceHolder1_ddl_group").val();
    _regi_type = $("#ContentPlaceHolder1_ddl_regi_type").val();
    _url = "/staff/registatus_excel_export?ret=" + _retreat + "&grp=" + _group + "&reg=" + _regi_type;

    //alert(_url);
    document.getElementById("ifrSelfReportExcel").src = _url;
}

function dataURLtoBlob(dataurl) {
    var arr = dataurl.split(','),
      mime = arr[0].match(/:(.*?);/)[1],
      bstr = atob(arr[1]),
      n = bstr.length,
      u8arr = new Uint8Array(n);
    while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
    }
    return new Blob([u8arr], {
        type: mime
    });
}

function downloadImg() {

    var imgSrc;
    var image;

    imgSrc = $("#ContentPlaceHolder1_hdImgUrl").val();    
    image = new Image();
    image.crossOrigin = "anonymous";
    image.src = imgSrc;
    var fileName = image.src.split("/").pop();
    image.onload = function () {
        var canvas = document.createElement('canvas');
        canvas.width = this.width;
        canvas.height = this.height;
        canvas.getContext('2d').drawImage(this, 0, 0);
        if (typeof window.navigator.msSaveBlob !== 'undefined') {
            window.navigator.msSaveBlob(dataURLtoBlob(canvas.toDataURL()), fileName);
        } else {
            var link = document.createElement('a');
            link.href = canvas.toDataURL();
            link.download = fileName;
            link.click();
        }
    };
}

function expenses_detail_print() {
    var _seq;
    var win;

    _seq = $("#ContentPlaceHolder1_hdSeq").val();
    win = window.open("/staff/in_ex_detail_print?seq=" + _seq + "&type=2", "PopupWin", "width=800,height=900");
    
}

function income_detail_print() {
    var _seq;
    var win;

    _seq = $("#ContentPlaceHolder1_hdSeq").val();
    win = window.open("/staff/in_ex_detail_print?seq=" + _seq + "&type=1", "PopupWin", "width=800,height=900");

}

function expenses_list_excel() {
    var _retreat;
    var _url;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val();
    _url = "/staff/in_ex_excel_export?ret=" + _retreat + "&type=2";
        
    document.getElementById("ifrSelfReportExcel").src = _url;
}

function income_list_excel() {
    var _retreat;
    var _url;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val();
    _url = "/staff/in_ex_excel_export?ret=" + _retreat + "&type=1";
        
    document.getElementById("ifrSelfReportExcel").src = _url;
}

function expenses_all_print() {
    var _retreat;
    var win;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val();
    win = window.open("/staff/in_ex_all_print?ret=" + _retreat + "&type=2", "PopupWin", "width=800,height=900");

}

function income_all_print() {
    var _retreat;
    var win;

    _retreat = $("#ContentPlaceHolder1_ddl_retreat").val();
    win = window.open("/staff/in_ex_all_print?ret=" + _retreat + "&type=1", "PopupWin", "width=800,height=900");

}
