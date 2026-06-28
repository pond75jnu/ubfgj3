<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="modify02.aspx.cs" Inherits="info_modify02" %>
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
                                <div class="site-info-label">기존 질문</div>
                                <div class="site-info-control-wrap">
                                    <div class="site-info-readonly-box">
                                        <%=my_question %>
                                    </div>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtMyPassword" class="site-info-label">로그인 비밀번호</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtMyPassword" TextMode="Password" runat="server" CssClass="site-info-input"></asp:TextBox>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtNewQuestion" class="site-info-label">새 본인확인 질문</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtNewQuestion" runat="server" CssClass="site-info-input"></asp:TextBox>
                                </div>
                            </div>
                            <div class="site-info-field">
                                <label for="ContentPlaceHolder1_txtAnswer" class="site-info-label">질문 답변</label>
                                <div class="site-info-control-wrap">
                                    <asp:TextBox ID="txtAnswer" runat="server" CssClass="site-info-input"></asp:TextBox>
                                </div>
                            </div>
                            <div class="site-info-actions">
                                <asp:Button ID="btnChangeQuestionAnswer" Text="확인" runat="server" CssClass="site-info-button site-info-button-primary" OnClientClick="return uModiPwdQuestion();" OnClick="btnChangeQuestionAnswer_Click" />
                                <input type="button" value="취소" class="site-info-button site-info-button-secondary" onclick="gomain();" />
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    </section>
</asp:Content>

