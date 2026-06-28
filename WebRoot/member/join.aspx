<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="join.aspx.cs" Inherits="member_join" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <section class="mx-auto w-full max-w-screen-2xl px-4 py-8 text-ink sm:px-6 lg:px-8">
        <div class="bg-parchment px-4 py-10 sm:px-6 lg:px-8">
            <div class="mx-auto max-w-4xl rounded-apple-lg border border-hairline bg-white p-6">
                <h2 class="text-3xl font-semibold leading-tight text-ink">회원가입</h2>

                <div id="divJoinStep01" runat="server" class="mt-8 space-y-6">
                    <div>
                        <label for="ContentPlaceHolder1_txtJoinID" class="mb-2 block text-sm font-semibold text-ink">아이디</label>
                        <div class="flex flex-col gap-3 sm:flex-row">
                            <asp:TextBox ID="txtJoinID" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon2"></asp:TextBox>
                            <asp:Button ID="btnIdChk" Text="아이디중복확인" runat="server" CssClass="inline-flex min-h-11 w-full shrink-0 items-center justify-center rounded-pill border border-action bg-white px-5 py-3 text-base font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" OnClientClick="return idCheck();" OnClick="btnIdChk_Click" />
                        </div>
                        <div class="mt-2 text-sm leading-relaxed">
                            <span id="txtidOK" style="color: blue; display: none;">※ 사용가능한 아이디 입니다.</span>
                            <span id="txtidNO" style="color: red; display: none;">※ 이미 사용중인 아이디입니다.</span>
                            <div class="displaynone">
                                <input id="txtChkResult" />
                                <iframe id="ifrChkID" runat="server"></iframe>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <label for="ContentPlaceHolder1_txtJoinPWD" class="mb-2 block text-sm font-semibold text-ink">비밀번호(7자이상, 특수문자포함)</label>
                            <asp:TextBox ID="txtJoinPWD" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3" TextMode="Password"></asp:TextBox>
                        </div>
                        <div>
                            <label for="ContentPlaceHolder1_txtJoinPWD2" class="mb-2 block text-sm font-semibold text-ink">비밀번호확인</label>
                            <asp:TextBox ID="txtJoinPWD2" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3" TextMode="Password"></asp:TextBox>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <label for="ContentPlaceHolder1_txtConfirm01" class="mb-2 block text-sm font-semibold text-ink">본인 확인 질문(비밀번호 분실 시)</label>
                            <asp:TextBox ID="txtConfirm01" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3" placeholder="질문예시) 존경하는 인물"></asp:TextBox>
                        </div>
                        <div>
                            <label for="ContentPlaceHolder1_txtConfirm02" class="mb-2 block text-sm font-semibold text-ink">본인 확인 답변</label>
                            <asp:TextBox ID="txtConfirm02" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3" placeholder="답변예시) 요셉"></asp:TextBox>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <label for="ContentPlaceHolder1_txtJoinNM" class="mb-2 block text-sm font-semibold text-ink">성명</label>
                            <asp:TextBox ID="txtJoinNM" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3"></asp:TextBox>
                        </div>
                        <div>
                            <label for="ContentPlaceHolder1_txtJoinEMAIL" class="mb-2 block text-sm font-semibold text-ink">이메일</label>
                            <asp:TextBox ID="txtJoinEMAIL" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" aria-describedby="button-addon3" placeholder="id@example.com" TextMode="Email"></asp:TextBox>
                            <div id="divEmailAlert" runat="server" visible="false" class="mt-2 text-sm text-red-600">
                                <span>※ 다른 사용자가 사용 중인 이메일입니다. 이메일을 다시 입력하십시오.</span>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <label for="ContentPlaceHolder1_ddl_group" class="mb-2 block text-sm font-semibold text-ink">요회</label>
                            <asp:DropDownList ID="ddl_group" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 pr-10 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" DataValueField="seq" DataTextField="belong_nm"></asp:DropDownList>
                        </div>
                        <div>
                            <label for="ContentPlaceHolder1_ddl_type" class="mb-2 block text-sm font-semibold text-ink">회원구분</label>
                            <asp:DropDownList ID="ddl_type" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 pr-10 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus">
                                <asp:ListItem Value="-1">== 회원구분선택 ==</asp:ListItem>
                                <asp:ListItem Value="user">요회담당자</asp:ListItem>
                                <asp:ListItem Value="manager">실무자</asp:ListItem>
                                <asp:ListItem Value="admin">시스템관리자</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="flex flex-col gap-3 pt-2 sm:flex-row">
                        <asp:Button ID="btnStep02" Text="확인" runat="server" CssClass="inline-flex min-h-11 w-full items-center justify-center rounded-pill bg-action px-5 py-3 text-base font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" OnClientClick="return uJoinConfirm('step02');" OnClick="btnStep02_Click" />
                        <asp:Button ID="btnStep03Cancel" Text="취소" runat="server" CssClass="inline-flex min-h-11 w-full items-center justify-center rounded-pill border border-hairline bg-white px-5 py-3 text-base font-normal text-ink transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" OnClientClick="return idcheckinit();" OnClick="btnStepCancel_Click" />
                    </div>
                    <div class="min-h-8 text-sm leading-relaxed text-red-600">
                        <asp:Label ID="lblCreateUsereErr" runat="server" ForeColor="Red" />
                    </div>
                </div>

                <div id="divJoinStep02" runat="server" class="mt-8 rounded-apple-lg border border-hairline bg-parchment p-6">
                    <h3 class="text-2xl font-semibold leading-tight text-ink">회원가입 완료</h3>
                    <ul class="mt-5 list-disc space-y-2 pl-5 text-base leading-relaxed text-zinc-700">
                        <li>본 시스템은 관리자의 승인 후 사용 가능합니다.</li>
                        <li>승인이 완료되면 이메일이 발송되오니 확인 후 사용하시기 바랍니다.</li>
                    </ul>
                    <div class="mt-6">
                        <asp:Button ID="btnStep03" Text="확인" runat="server" CssClass="inline-flex min-h-11 w-full items-center justify-center rounded-pill bg-action px-5 py-3 text-base font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" OnClientClick="return uJoinConfirm('step02');" OnClick="btnStep03_Click" />
                    </div>
                </div>
            </div>

            <asp:HiddenField ID="hdJoinMode" runat="server" />
            <asp:HiddenField ID="hdBelongCode" runat="server" />
            <asp:HiddenField ID="hdBelongName" runat="server" />
            <asp:HiddenField ID="hdUserTypeCode" runat="server" />
        </div>
    </section>
</asp:Content>


