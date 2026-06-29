<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="member_login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script>
        window.onload = function() {
            idsaveinit();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">


    <section class="mx-auto w-full max-w-screen-2xl px-4 py-8 text-ink sm:px-6 lg:px-8">
        <div class="bg-parchment px-4 py-10 sm:px-6 lg:px-8">
            <div class="mx-auto w-full max-w-md rounded-apple-lg border border-hairline bg-white p-6">
                <h1 class="text-3xl font-semibold leading-tight text-ink">Login</h1>

                <div class="mt-6 space-y-5">
                    <div>
                        <label for="ContentPlaceHolder1_txtLoginID" class="mb-2 block text-sm font-semibold text-ink">아이디</label>
                        <asp:TextBox ID="txtLoginID" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" placeholder="아이디"></asp:TextBox>
                    </div>
                    <div>
                        <label for="ContentPlaceHolder1_txtLoginPWD" class="mb-2 block text-sm font-semibold text-ink">비밀번호</label>
                        <asp:TextBox ID="txtLoginPWD" runat="server" CssClass="block h-11 w-full rounded-pill border border-hairline bg-white px-5 text-base text-ink outline-none transition focus:border-action-focus focus:ring-2 focus:ring-action-focus" placeholder="비밀번호" TextMode="Password"></asp:TextBox>
                    </div>

                    <div class="flex flex-col gap-3 text-sm text-zinc-700 sm:flex-row sm:items-center sm:justify-between">
                        <label class="inline-flex min-h-11 items-center gap-2">
                            <input type="checkbox" id="checkId" name="checkId" class="h-4 w-4 rounded border-hairline text-action focus:ring-action-focus" />
                            <span>ID 저장</span>
                        </label>
                        <div>
                            <a href="/member/findid" class="text-action">아이디</a>
                            <span class="px-1 text-zinc-500">/</span>
                            <a href="/member/findpwd" class="text-action">비밀번호</a>
                            <span>찾기</span>
                        </div>
                    </div>
                    <asp:CheckBox ID="chkbRememberMe" runat="server" Text="로그인 기억하기" CssClass="displaynone" />
                    <asp:Button ID="btnLogin" runat="server" CssClass="inline-flex min-h-11 w-full items-center justify-center rounded-pill bg-action px-5 py-3 text-base font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" OnClick="btnLogin_Click" Text="로그인" />
                    <div class="min-h-8 text-sm leading-relaxed text-red-600">
                        <asp:Label ID="lblLoginFailure" runat="server" ForeColor="Red" />
                    </div>
                </div>
            </div>
        </div>
    </section>


</asp:Content>

