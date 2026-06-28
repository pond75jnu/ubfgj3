<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <section class="site-home">
        <div class="site-home-hero">
            <div class="site-home-hero-content">
                <p class="site-home-kicker">UBF 광주3부</p>
                <h2 id="mTitle" runat="server" class="site-home-title"></h2>
                <p id="mDesc" runat="server" class="site-home-desc"></p>
                <asp:Button ID="btnFileDown" runat="server" Text="프로그램 세부보기" CssClass="site-home-button" OnClick="btnFileDown_Click" />
            </div>
            <div class="site-home-hero-label">UBF 광주 3부 수양회 관리 프로그램</div>
        </div>

        <div class="site-home-cards">
            <section class="site-home-card">
                <h2>장소 / 기간</h2>
                <p id="mPlaceTerm" runat="server"></p>
            </section>
            <section class="site-home-card">
                <h2>수양회비</h2>
                <p id="mDuesInfo" runat="server"></p>
            </section>
        </div>
    </section>
</asp:Content>
