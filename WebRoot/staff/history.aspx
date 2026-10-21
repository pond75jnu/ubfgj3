<%@ Page Title="역대 실무자" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="history.aspx.cs" Inherits="staff_history" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="/common/css/staff-history.css?v=1" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="site-panel history-page">
        <h1 class="site-page-title">역대 실무자</h1>
        <p class="history-intro">연도와 수양회별 실무자 및 실무통장 정보를 확인하세요.</p>
        <p class="history-help">별도로 수정한 기록이 없으면 수양회 입금계좌와 예금주를 표시합니다.</p>
        <div class="history-filters">
            <div><asp:Label runat="server" AssociatedControlID="ddlYear" Text="연도" />
                <asp:DropDownList ID="ddlYear" runat="server" CssClass="ui-select" AutoPostBack="true" OnSelectedIndexChanged="YearChanged" /></div>
            <div><asp:Label runat="server" AssociatedControlID="ddlRetreat" Text="수양회" />
                <asp:DropDownList ID="ddlRetreat" runat="server" CssClass="ui-select" AutoPostBack="true" OnSelectedIndexChanged="RetreatChanged" /></div>
        </div>
        <asp:Label ID="lblMessage" runat="server" CssClass="history-message" role="status" aria-live="polite" />
        <asp:Panel ID="pnlEdit" runat="server" Visible="false" CssClass="history-editor">
            <h2><asp:Literal ID="litEditTitle" runat="server" Mode="Encode" /> 정보 수정</h2>
            <asp:HiddenField ID="hdRetreat" runat="server" />
            <asp:Label runat="server" AssociatedControlID="txtStaff" Text="실무자" />
            <asp:TextBox ID="txtStaff" runat="server" CssClass="ui-input" MaxLength="300" placeholder="예: 홍길동, 김영희" />
            <asp:Label runat="server" AssociatedControlID="txtBank" Text="실무통장" />
            <asp:TextBox ID="txtBank" runat="server" CssClass="ui-input" MaxLength="300" placeholder="은행명 · 계좌번호 · 예금주" />
            <p class="history-help">이 화면의 실무통장 기록만 변경됩니다. 수양회 안내의 입금계좌는 수양회 관리에서 수정하세요.</p>
            <div class="history-actions">
                <asp:Button runat="server" Text="저장" CssClass="site-button site-button-primary" OnClick="Save" />
                <asp:Button runat="server" Text="취소" CssClass="site-button site-button-secondary" OnClick="Cancel" CausesValidation="false" />
            </div>
        </asp:Panel>
        <p class="history-count"><asp:Literal ID="litCount" runat="server" Mode="Encode" /></p>
        <div class="history-list">
            <asp:Repeater ID="rptHistory" runat="server" OnItemCommand="EditRecord">
                <ItemTemplate>
                    <article class="history-card">
                        <header><span class="history-year"><%#: Eval("retreat_year") %></span>
                            <h2><%#: Eval("retreat_name") %></h2>
                            <p><%#: Eval("start_date") %> ~ <%#: Eval("end_date") %></p></header>
                        <dl><div><dt>실무자</dt><dd><%#: Display(Eval("staff_names")) %></dd></div>
                            <div><dt>실무통장</dt><dd><%#: Display(Eval("bank_info")) %></dd></div></dl>
                        <asp:Button runat="server" Text="정보 수정" CssClass="site-button site-button-secondary" CommandName="EditRecord" CommandArgument='<%# Eval("seq") %>' />
                    </article>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>
