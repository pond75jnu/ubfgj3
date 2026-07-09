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
                <a id="btnProgramView" runat="server" class="site-home-button" href="/retreat_program" target="_blank" rel="noopener" data-retreat-program-open>프로그램 세부보기</a>
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

    <div class="site-program-modal" style="display: none;" role="dialog" aria-modal="true" aria-labelledby="siteProgramModalTitle" data-retreat-program-modal>
        <div class="site-program-backdrop" data-retreat-program-close></div>
        <section class="site-program-dialog" aria-describedby="siteProgramModalDesc" data-retreat-program-dialog>
            <header class="site-program-header">
                <div>
                    <p class="site-program-kicker">수양회 안내</p>
                    <h2 id="siteProgramModalTitle">프로그램 세부보기</h2>
                    <p id="siteProgramModalDesc">브라우저 PDF 뷰어로 안내 파일을 표시합니다.</p>
                </div>
                <button type="button" class="site-program-close" aria-label="닫기" data-retreat-program-close>&times;</button>
            </header>
            <div class="site-program-body">
                <iframe class="site-program-frame" title="수양회 프로그램 PDF" data-retreat-program-frame></iframe>
            </div>
            <footer class="site-program-actions">
                <a class="site-button site-button-secondary" href="/retreat_program" target="_blank" rel="noopener">새 탭으로 열기</a>
                <button type="button" class="site-button site-button-primary" data-retreat-program-close>닫기</button>
            </footer>
        </section>
    </div>
</asp:Content>
