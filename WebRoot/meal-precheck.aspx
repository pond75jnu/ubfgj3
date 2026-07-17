<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="meal-precheck.aspx.cs" Inherits="meal_precheck" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="robots" content="noindex,nofollow" />
    <link rel="stylesheet" href="/common/css/meal-precheck.css?v=meal-precheck-11" />
    <script defer src="/common/js/meal-precheck.js?v=meal-precheck-11"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <section class="site-meal-public">
        <div class="site-meal-public-header">
            <p class="site-meal-kicker">UBF 광주3부</p>
            <h1>수양회 식사여부 사전조사</h1>
            <p>요회별 명단에서 실제 식사 인원을 선택해 주세요.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" CssClass="site-alert" Visible="false" role="status" aria-live="polite">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlAccess" runat="server" CssClass="site-meal-access-card" Visible="false">
            <div class="site-meal-access-icon" aria-hidden="true">🔒</div>
            <h2>조사 페이지 암호 입력</h2>
            <p>전달받은 공용 암호를 입력하면 식사여부 조사에 참여할 수 있습니다.</p>
            <div class="site-meal-password-row">
                <label for="<%= txtAccessPassword.ClientID %>">공용 암호</label>
                <asp:TextBox ID="txtAccessPassword" runat="server" CssClass="ui-input" TextMode="Password" MaxLength="100" autocomplete="current-password" />
                <asp:Button ID="btnAccess" runat="server" CssClass="site-button site-button-primary" Text="확인" OnClick="btnAccess_Click" />
            </div>
            <asp:Label ID="lblAccessState" runat="server" CssClass="site-meal-access-state" aria-live="polite" />
        </asp:Panel>

        <asp:Panel ID="pnlSurvey" runat="server" Visible="false">
            <div class="site-meal-survey-filter" data-meal-sticky-filter>
                <div>
                    <label for="<%= ddlRetreat.ClientID %>">수양회</label>
                    <asp:DropDownList ID="ddlRetreat" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="retreat_name" />
                </div>
                <div>
                    <label for="<%= ddlGroup.ClientID %>">요회</label>
                    <asp:DropDownList ID="ddlGroup" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="belong_nm" AutoPostBack="true" OnSelectedIndexChanged="ddlGroup_SelectedIndexChanged" data-meal-group-select="true" />
                </div>
            </div>

            <div class="site-meal-survey-meta">
                <div>
                    <h2><asp:Label ID="lblGroupTitle" runat="server" /></h2>
                    <asp:Label ID="lblSubmissionState" runat="server" />
                </div>
                <div class="site-meal-survey-meta-actions">
                    <div class="site-meal-selection-count" aria-live="polite">
                        <span data-meal-selection-label>선택한 식사</span>
                        <strong data-meal-selection-count>0</strong><span data-meal-selection-unit>건</span>
                    </div>
                </div>
            </div>

            <asp:Literal ID="litSurvey" runat="server" />

            <div class="site-meal-add-member-row">
                <button id="btnOpenAddMember" runat="server" type="button" class="site-button site-button-secondary site-button-sm" data-meal-add-member-open>신규인원 추가</button>
            </div>

            <div class="site-actions site-meal-public-actions">
                <asp:Button ID="btnSaveSurvey" runat="server" CssClass="site-button site-button-primary" Text="식사여부 저장" OnClientClick="return mealPrecheckConfirmEmptySelection();" OnClick="btnSaveSurvey_Click" data-meal-save-button="true" />
            </div>

            <asp:HiddenField ID="hdRetreat" runat="server" />
            <asp:HiddenField ID="hdSubmissionRevision" runat="server" />
            <asp:HiddenField ID="hdCsrfToken" runat="server" />
        </asp:Panel>
    </section>

    <asp:Panel ID="pnlAddMemberModal" runat="server" CssClass="site-meal-modal site-meal-add-member-modal" role="dialog" aria-modal="true" aria-labelledby="mealAddMemberTitle" data-meal-add-member-modal hidden="hidden">
        <button type="button" class="site-meal-modal-backdrop" aria-label="신규인원 추가 창 닫기" data-meal-add-member-close></button>
        <section class="site-meal-modal-dialog site-meal-add-member-dialog" data-meal-add-member-dialog>
            <header class="site-meal-modal-header">
                <div>
                    <p class="site-meal-modal-kicker">요회 명단</p>
                    <h2 id="mealAddMemberTitle">신규인원 추가</h2>
                    <p class="site-meal-modal-meta">추가한 인원은 요회 구성원 관리에도 자동 반영됩니다.</p>
                </div>
                <button type="button" class="site-meal-modal-close" aria-label="닫기" data-meal-add-member-close>&times;</button>
            </header>
            <div class="site-meal-modal-body">
                <div class="site-meal-add-member-form">
                    <div class="site-meal-add-member-field is-wide">
                        <label for="<%= txtNewMemberName.ClientID %>">성명</label>
                        <asp:TextBox ID="txtNewMemberName" runat="server" CssClass="ui-input" MaxLength="100" autocomplete="name" />
                    </div>
                    <div class="site-meal-add-member-field">
                        <label for="<%= ddlNewMemberType.ClientID %>">회원구분</label>
                        <asp:DropDownList ID="ddlNewMemberType" runat="server" CssClass="ui-select">
                            <asp:ListItem Value="1">목자</asp:ListItem>
                            <asp:ListItem Value="2">목동</asp:ListItem>
                            <asp:ListItem Value="3" Selected="True">양</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="site-meal-add-member-field">
                        <label for="<%= ddlNewMemberCategory.ClientID %>">학사/학생</label>
                        <asp:DropDownList ID="ddlNewMemberCategory" runat="server" CssClass="ui-select">
                            <asp:ListItem Value="graduate">학사</asp:ListItem>
                            <asp:ListItem Value="student" Selected="True">학생</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <footer class="site-meal-modal-footer">
                <button type="button" class="site-button site-button-secondary" data-meal-add-member-close>취소</button>
                <asp:Button ID="btnAddMember" runat="server" CssClass="site-button site-button-primary" Text="확인" OnClientClick="return mealPrecheckValidateNewMember();" OnClick="btnAddMember_Click" data-meal-add-member-submit="true" />
            </footer>
        </section>
    </asp:Panel>

    <asp:Panel ID="pnlErrorModal" runat="server" CssClass="site-meal-modal site-meal-error-modal" role="alertdialog" aria-modal="true" aria-labelledby="mealPublicErrorTitle" aria-describedby="mealPublicErrorMessage" data-meal-error-modal hidden="hidden">
        <button type="button" class="site-meal-modal-backdrop" aria-label="오류 안내 창 닫기" data-meal-error-close></button>
        <section class="site-meal-modal-dialog site-meal-error-dialog" data-meal-error-dialog>
            <header class="site-meal-modal-header site-meal-error-header">
                <div>
                    <p class="site-meal-modal-kicker">처리 오류</p>
                    <h2 id="mealPublicErrorTitle">확인이 필요합니다</h2>
                </div>
                <button type="button" class="site-meal-modal-close" aria-label="닫기" data-meal-error-close>&times;</button>
            </header>
            <div class="site-meal-modal-body site-meal-error-body">
                <span class="site-meal-error-icon" aria-hidden="true">!</span>
                <p id="mealPublicErrorMessage" class="site-meal-error-message" data-meal-error-message><asp:Label ID="lblErrorModalMessage" runat="server" /></p>
            </div>
            <footer class="site-meal-modal-footer">
                <button type="button" class="site-button site-button-primary" data-meal-error-close>확인</button>
            </footer>
        </section>
    </asp:Panel>
</asp:Content>
