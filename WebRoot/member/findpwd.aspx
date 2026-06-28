<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="findpwd.aspx.cs" Inherits="member_findpwd" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .text_left {
            text-align: left;
        }

        .padding_bottom10 {
            padding-bottom: 10px;
        }

        .padding_bottom20 {
            padding-bottom: 20px;
        }

        .padding_bottom30 {
            padding-bottom: 30px;
        }

        .padding_bottom40 {
            padding-bottom: 40px;
        }

        .padding_bottom50 {
            padding-bottom: 50px;
        }

        .fail_message {
            color: red;
            padding-top: 10px;
            padding-bottom: 10px;
        }

        .pwd_change_table {
            width: 100%;
        }

            .pwd_change_table table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0 12px;
            }

            .pwd_change_table td {
                padding: 2px 0;
                vertical-align: top;
            }

        .validator_style {
            color: red;
            font-weight: bold;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <section class="mx-auto w-full max-w-screen-2xl px-4 py-8 text-ink sm:px-6 lg:px-8">
        <div class="bg-parchment px-4 py-10 sm:px-6 lg:px-8">
            <div class="mx-auto w-full max-w-xl rounded-apple-lg border border-hairline bg-white p-6">
                <div class="overflow-x-auto">
                    <asp:PasswordRecovery ID="PasswordRecovery1" runat="server" CssClass="pwd_change_table"
                        UserNameTitleText="비밀번호를 잊으셨나요?"
                        TitleTextStyle-CssClass="text-left text-3xl font-semibold leading-tight text-ink"
                        UserNameInstructionText="비밀번호를 찾으려면 아이디를 입력 후 전송 버튼을 누르십시오."
                        InstructionTextStyle-CssClass="text-left pb-5 text-base leading-relaxed text-zinc-700"
                        UserNameLabelText="아이디"
                        LabelStyle-CssClass="text-left pb-2 text-sm font-semibold text-ink"
                        QuestionTitleText="ID 확인 완료!!"
                        QuestionInstructionText="비밀번호를 찾으려면 다음 질문에 대답하십시오. (회원 가입 시 등록한 질문)"
                        QuestionLabelText="본인확인질문:"
                        ValidatorTextStyle-CssClass="text-red-600 font-semibold"
                        SuccessText="회원 가입 시 등록했던 이메일로 임시 비밀번호를 발송하였습니다.<br><br>확인 후 로그인 하여 비밀번호를 변경하시기 바랍니다."
                        TextBoxStyle-CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus"
                        SubmitButtonStyle-CssClass="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-5 py-3 text-base font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus"
                        FailureTextStyle-CssClass="text-left py-3 text-sm font-semibold text-red-600" OnSendingMail="PasswordRecovery1_SendingMail">
                    </asp:PasswordRecovery>
                </div>
            </div>
        </div>
    </section>
</asp:Content>

