<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="findid.aspx.cs" Inherits="member_findid" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <section class="mx-auto w-full max-w-screen-2xl px-4 py-8 text-ink sm:px-6 lg:px-8">
        <div class="bg-parchment px-4 py-10 sm:px-6 lg:px-8">
            <div class="mx-auto w-full max-w-xl rounded-apple-lg border border-hairline bg-white p-6">
                <h2 class="text-3xl font-semibold leading-tight text-ink">아이디 찾기</h2>
                <p class="mt-3 text-base leading-relaxed text-zinc-700">가입 당시 등록한 이름과 이메일 정보를 입력하십시오.</p>

                <div class="mt-6 space-y-5">
                    <div>
                        <label for="ContentPlaceHolder1_txtNAME" class="mb-2 block text-sm font-semibold text-ink">이름</label>
                        <asp:TextBox ID="txtNAME" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus"></asp:TextBox>
                    </div>
                    <div>
                        <label for="ContentPlaceHolder1_txtEMAIL" class="mb-2 block text-sm font-semibold text-ink">이메일</label>
                        <asp:TextBox ID="txtEMAIL" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-3 pt-2 sm:flex-row">
                        <asp:Button ID="btnSubmit" Text="확인" runat="server" CssClass="inline-flex min-h-11 w-full items-center justify-center rounded-pill bg-action px-5 py-3 text-base font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" OnClientClick="return uFindidConfirm();" OnClick="btnSubmit_Click" />
                        <input type="button" value="취소" class="inline-flex min-h-11 w-full items-center justify-center rounded-pill border border-hairline bg-white px-5 py-3 text-base font-normal text-ink transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus sm:w-auto" onclick="findidcancel();" />
                    </div>
                    <div class="min-h-8 text-base font-semibold leading-relaxed text-action">
                        <asp:Label ID="lblResult" runat="server" ForeColor="Blue"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>

