<%@ Control Language="C#" AutoEventWireup="true" CodeFile="top_nav.ascx.cs" Inherits="usercontrol_top_nav" %>

<nav class="site-global-nav" aria-label="주 메뉴" data-site-nav>
    <div class="site-nav-inner">
        <a class="site-nav-brand" href="/">
            <img class="site-nav-logo" src="/common/images/ubf-logo-white.png" alt="UBF" />
            <span>광주3부</span>
        </a>
        <button class="site-nav-toggle" type="button" aria-expanded="false" aria-label="메뉴 열기" data-site-nav-toggle>
            <span class="site-nav-toggle-bar"></span>
            <span class="site-nav-toggle-bar"></span>
            <span class="site-nav-toggle-bar"></span>
        </button>
        <div id="divTopMenu" runat="server" class="site-nav-menu" data-site-nav-menu>
        </div>
    </div>
</nav>

<asp:Panel ID="pnlRetreatSwitch" runat="server" CssClass="site-retreat-switch-modal" Style="display: none;" data-retreat-switch-modal role="dialog" aria-modal="true" aria-labelledby="retreatSwitchTitle">
    <div class="site-retreat-switch-backdrop" data-retreat-switch-close></div>
    <div class="site-retreat-switch-dialog" role="document">
        <div class="site-retreat-switch-header">
            <div>
                <p class="site-retreat-switch-kicker">현재 수양회</p>
                <h2 id="retreatSwitchTitle">수양회 전환</h2>
            </div>
            <button type="button" class="site-retreat-switch-close" aria-label="닫기" data-retreat-switch-close>×</button>
        </div>
        <div class="site-retreat-switch-body">
            <p class="site-retreat-switch-current">
                <asp:Label ID="lblCurrentRetreat" runat="server"></asp:Label>
            </p>
            <asp:Label ID="lblRetreatSwitchSelect" runat="server" CssClass="site-retreat-switch-label" AssociatedControlID="ddlRetreatSwitch" Text="전환할 수양회"></asp:Label>
            <asp:DropDownList ID="ddlRetreatSwitch" runat="server" CssClass="ui-select site-retreat-switch-select"></asp:DropDownList>
            <asp:Label ID="lblRetreatSwitchAlert" runat="server" CssClass="site-retreat-switch-alert" Visible="false"></asp:Label>
        </div>
        <div class="site-retreat-switch-actions">
            <button type="button" class="site-button site-button-secondary" data-retreat-switch-close>취소</button>
            <asp:Button ID="btnRetreatSwitchSave" runat="server" Text="전환" CssClass="site-button site-button-primary" OnClick="btnRetreatSwitchSave_Click" OnClientClick="return confirmRetreatSwitch();" />
        </div>
    </div>
</asp:Panel>
