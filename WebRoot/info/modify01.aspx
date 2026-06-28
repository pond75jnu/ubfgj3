<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="modify01.aspx.cs" Inherits="info_modify01" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <section class="site-panel site-info">
        <div class="site-layout-row">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />

            <main class="site-content-main site-info-main">
                <section class="site-info-card">
                    <header class="site-info-header">
                        <h2 class="site-info-title"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h2>
                    </header>

                    <div class="site-info-body">
                        <div class="site-info-form">
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtID" class="site-info-label">아이디</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtID" runat="server" CssClass="site-info-input" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtKorNm" class="site-info-label">성명</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtKorNm" runat="server" CssClass="site-info-input"></asp:TextBox>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtEmail" class="site-info-label">이메일</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="site-info-input"></asp:TextBox>
                                    <div class="site-info-alert">
                                        <asp:Label ID="lblEmailAlert" runat="server" ForeColor="Red"></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_ddl_group" class="site-info-label">요회</label>
                                <div class="site-info-control-wrap">
                                    <asp:DropDownList ID="ddl_group" runat="server" CssClass="site-info-select" DataValueField="seq" DataTextField="belong_nm" Enabled="false"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_ddl_type" class="site-info-label">역할</label>
                                <div class="site-info-control-wrap">
                                    <asp:DropDownList ID="ddl_type" runat="server" CssClass="site-info-select" Enabled="false">
                                        <asp:ListItem Value="user">요회담당자</asp:ListItem>
                                        <asp:ListItem Value="manager">실무자</asp:ListItem>
                                        <asp:ListItem Value="admin">시스템관리자</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_ddl_status" class="site-info-label">계정상태</label>
                                <div class="site-info-control-wrap">
                                    <asp:DropDownList ID="ddl_status" runat="server" CssClass="site-info-select" Enabled="false">
                                        <asp:ListItem Value="1">사용중</asp:ListItem>
                                        <asp:ListItem Value="0">계정잠금</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="site-info-actions">
                                <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="site-info-button site-info-button-primary" OnClick="btnSave_Click" OnClientClick="return uConfirm_modi01();" />
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    </section>


    <asp:HiddenField ID="hdBelong" runat="server" />
    <asp:HiddenField ID="hdBelongNm" runat="server" />
    <asp:HiddenField ID="hdKorNm" runat="server" />
    <asp:HiddenField ID="hdEmail" runat="server" />

</asp:Content>

