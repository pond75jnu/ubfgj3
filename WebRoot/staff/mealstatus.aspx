<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="mealstatus.aspx.cs" Inherits="staff_mealstatus" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link rel="stylesheet" href="/common/css/meal-precheck.css?v=meal-precheck-13" />
    <script defer src="/common/js/meal-precheck.js?v=meal-precheck-13"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="site-panel site-meal-admin">
        <div class="site-layout-row">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="site-content-main site-meal-admin-main">
                <h1 class="site-page-title"><asp:Label ID="lblPageTitle" runat="server" /></h1>

                <div class="site-meal-control-card">
                    <div class="site-filterbar site-meal-filterbar">
                        <label class="site-meal-field-label" for="<%= ddlRetreat.ClientID %>">수양회</label>
                        <asp:DropDownList ID="ddlRetreat" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="retreat_name" />
                    </div>
                    <nav class="site-meal-tabs" aria-label="식사수량파악 메뉴">
                        <a id="tabSummary" runat="server" href="/staff/mealstatus">식사수량 현황</a>
                        <a id="tabConfig" runat="server" href="/staff/mealstatus?mode=config">사전설정</a>
                    </nav>
                </div>

                <asp:Panel ID="pnlMessage" runat="server" CssClass="site-alert" Visible="false" role="status" aria-live="polite">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlSummary" runat="server" Visible="false">
                    <div class="site-meal-section-heading">
                        <div>
                            <h2>요회별 식사수량</h2>
                            <p>요회명을 선택하면 구성원별 상세 내용을 확인할 수 있습니다.</p>
                        </div>
                        <a class="site-button site-button-secondary site-meal-excel-button" href="/staff/mealstatus_excel_export" data-meal-excel-download>엑셀 다운로드</a>
                    </div>
                    <asp:Literal ID="litSummary" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlConfig" runat="server" Visible="false">
                    <div class="site-meal-section-heading">
                        <div>
                            <h2>식사 제공 사전설정</h2>
                            <p>실제로 제공되는 날짜별 아침·점심·저녁을 선택하세요.</p>
                        </div>
                    </div>
                    <asp:Panel ID="pnlDefaultNotice" runat="server" CssClass="site-help site-meal-default-notice" Visible="false">
                        기본값 적용 중입니다. 저장하면 현재 설정으로 확정됩니다.
                    </asp:Panel>
                    <div class="site-meal-config-scroll">
                        <asp:Literal ID="litConfig" runat="server" />
                    </div>
                    <div class="site-actions site-meal-actions">
                        <asp:Button ID="btnSaveConfig" runat="server" CssClass="site-button site-button-primary" Text="설정 저장" OnClick="btnSaveConfig_Click" />
                    </div>
                    <asp:Panel ID="pnlForceSave" runat="server" CssClass="site-alert site-alert-warning" Visible="false">
                        <asp:Label ID="lblForceMessage" runat="server" />
                        <asp:Button ID="btnForceSave" runat="server" CssClass="site-button site-button-danger site-button-sm" Text="기존 선택 삭제 후 저장" OnClick="btnForceSave_Click" />
                    </asp:Panel>
                    <asp:HiddenField ID="hdConfigRevision" runat="server" />
                    <asp:HiddenField ID="hdPendingConfigXml" runat="server" />
                </asp:Panel>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlDetailModal" runat="server" CssClass="site-meal-modal site-meal-detail-modal" Visible="false" role="dialog" aria-modal="true" aria-labelledby="mealDetailTitle" data-meal-modal>
        <button type="button" class="site-meal-modal-backdrop" aria-label="상세 창 닫기" data-meal-modal-close></button>
        <section class="site-meal-modal-dialog" data-meal-modal-dialog>
            <header class="site-meal-modal-header">
                <div>
                    <p class="site-meal-modal-kicker">요회별 상세</p>
                    <h2 id="mealDetailTitle"><asp:Label ID="lblDetailTitle" runat="server" /></h2>
                    <asp:Label ID="lblDetailMeta" runat="server" CssClass="site-meal-modal-meta" />
                    <a id="lnkEditMeal" runat="server" class="site-button site-button-secondary site-meal-modal-edit-link">식사인원 수정</a>
                </div>
                <button type="button" class="site-meal-modal-close" aria-label="닫기" data-meal-modal-close>&times;</button>
            </header>
            <div class="site-meal-modal-body">
                <asp:Literal ID="litDetail" runat="server" />
            </div>
            <footer class="site-meal-modal-footer">
                <button type="button" class="site-button site-button-primary" data-meal-modal-close>닫기</button>
            </footer>
        </section>
    </asp:Panel>

    <asp:Panel ID="pnlErrorModal" runat="server" CssClass="site-meal-modal site-meal-error-modal" role="alertdialog" aria-modal="true" aria-labelledby="mealStaffErrorTitle" aria-describedby="mealStaffErrorMessage" data-meal-error-modal hidden="hidden">
        <button type="button" class="site-meal-modal-backdrop" aria-label="오류 안내 창 닫기" data-meal-error-close></button>
        <section class="site-meal-modal-dialog site-meal-error-dialog" data-meal-error-dialog>
            <header class="site-meal-modal-header site-meal-error-header">
                <div>
                    <p class="site-meal-modal-kicker">처리 오류</p>
                    <h2 id="mealStaffErrorTitle">확인이 필요합니다</h2>
                </div>
                <button type="button" class="site-meal-modal-close" aria-label="닫기" data-meal-error-close>&times;</button>
            </header>
            <div class="site-meal-modal-body site-meal-error-body">
                <span class="site-meal-error-icon" aria-hidden="true">!</span>
                <p id="mealStaffErrorMessage" class="site-meal-error-message" data-meal-error-message><asp:Label ID="lblErrorModalMessage" runat="server" /></p>
            </div>
            <footer class="site-meal-modal-footer">
                <button type="button" class="site-button site-button-primary" data-meal-error-close>확인</button>
            </footer>
        </section>
    </asp:Panel>
</asp:Content>
