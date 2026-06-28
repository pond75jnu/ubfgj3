<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="modify03.aspx.cs" Inherits="info_modify03" %>

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
                        <asp:ChangePassword ID="ChangePassword1" runat="server" CssClass="site-info-password-form"
                            CancelDestinationPageUrl="/"
                            ContinueButtonText="메인으로"
                            ContinueButtonStyle-CssClass="site-info-button site-info-button-primary"
                            ContinueDestinationPageUrl="/"
                            TitleTextStyle-CssClass="displaynone"
                            LabelStyle-CssClass="site-info-label"
                            TextBoxStyle-CssClass="site-info-input"
                            ChangePasswordButtonStyle-CssClass="site-info-button site-info-button-primary"
                            CancelButtonStyle-CssClass="site-info-button site-info-button-secondary"
                            FailureTextStyle-CssClass="site-info-failure"
                            PasswordLabelText="현재 비밀번호"
                            NewPasswordLabelText="새 비밀번호"
                            ConfirmNewPasswordLabelText="비밀번호 확인"
                            ChangePasswordButtonText="비밀번호 변경"
                            ConfirmPasswordCompareErrorMessage="[새 비밀번호]와 [비밀번호 확인]이 다릅니다."
                            ValidatorTextStyle-CssClass="site-info-failure"
                            ChangePasswordFailureText="[현재 비밀번호]가 잘못되었거나 [새 비밀번호]가 올바르지 않습니다.<br />[새 비밀번호]의 길이는 7자 이상이어야 하며, 영숫자가 아닌 문자가 1자 이상 포함되어 있어야 합니다." />
                    </div>
                </section>
            </main>
        </div>
    </section>


</asp:Content>

