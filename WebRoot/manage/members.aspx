<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="members.aspx.cs" Inherits="manage_members" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <div class="mx-auto w-full max-w-[1440px] px-4 py-6 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[340px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="min-w-0 rounded-[18px] border border-hairline bg-white p-4 sm:p-6">
                        <h5 class="text-[21px] font-semibold text-ink"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h5>
                        <hr class="my-4 border-0 border-t border-hairline" />
                        <div id="divList" runat="server" class="mt-6">

                            <div class="site-admin-filterbar">
                                <div>
                                    <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
                                        <div class="w-full sm:max-w-xs">
                                            <asp:TextBox ID="txtSearchName" runat="server" CssClass="ui-input site-admin-search-input" placeholder="이름 검색"></asp:TextBox>
                                        </div>
                                        <div>
                                            <asp:Button ID="btnSearch" runat="server" CssClass="site-button site-button-primary" OnClick="btnSearch_Click" Text="검색" />
                                        </div>
                                    </div>
                                </div>
                            </div>


                            <div class="mb-3 mt-6 text-sm font-semibold text-[#333333]">
                                사용자 목록
                            </div>
                            <div class="overflow-x-auto rounded-[18px] border border-hairline bg-white">
                                <asp:GridView ID="gvList" runat="server" DataKeyNames="login_id" AllowPaging="false" BorderColor="#e0e0e0" CssClass="min-w-full divide-y divide-hairline text-sm text-ink"
                                    ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                                    <Columns>
                                        <asp:BoundField DataField="num" HeaderText="연번">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="login_id" HeaderText="아이디">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="kor_nm" HeaderText="이름">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="email" HeaderText="이메일">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="belong_nm" HeaderText="요회">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="user_type" HeaderText="역할">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="IsApproved" HeaderText="상태">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>

                                    </Columns>
                                    <EmptyDataTemplate>
                                        <table class="min-w-full text-sm text-ink">
                                            <tr>
                                                <td class="px-4 py-6 text-center text-[#7a7a7a]" style="border: 0px none #ffffff;">조회 결과가 없습니다.
                                                </td>
                                            </tr>
                                        </table>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                        <div id="divWriteModify" runat="server" class="site-entry-form-section">
                            <div class="site-entry-form-title">
                                상세보기
                                <span class="site-entry-form-subtitle">회원 기본 정보와 권한 설정</span>
                            </div>
                            <div class="site-entry-form-card site-manage-form-card">
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_txtID">아이디</label>
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtID" runat="server" CssClass="ui-input site-readonly-input" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_txtKorNm">성명</label>
                                        <span class="site-required-mark">필수</span>
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtKorNm" runat="server" CssClass="ui-input"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_txtEmail">이메일</label>
                                        <span class="site-required-mark">필수</span>
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtEmail" runat="server" CssClass="ui-input"></asp:TextBox>
                                        <asp:Label ID="lblEmailAlert" runat="server" ForeColor="Red" CssClass="site-form-error"></asp:Label>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_ddl_group">요회</label>
                                    </div>
                                    <div>
                                        <asp:DropDownList ID="ddl_group" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="belong_nm"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_ddl_type">역할</label>
                                    </div>
                                    <div>
                                        <asp:DropDownList ID="ddl_type" runat="server" CssClass="ui-select">
                                            <asp:ListItem Value="user">요회담당자</asp:ListItem>
                                            <asp:ListItem Value="manager">실무자</asp:ListItem>
                                            <asp:ListItem Value="admin">시스템관리자</asp:ListItem>
                                        </asp:DropDownList>
                                        <p class="site-form-help">역할 변경은 메뉴 접근 권한과 관리자 기능 노출에 영향을 줍니다.</p>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_ddl_status">계정상태</label>
                                    </div>
                                    <div>
                                        <asp:DropDownList ID="ddl_status" runat="server" CssClass="ui-select">
                                            <asp:ListItem Value="1">사용중</asp:ListItem>
                                            <asp:ListItem Value="0">계정잠금</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>

                            <div class="site-password-reset" id="trInitPWD" runat="server" visible="false">
                                <div class="site-password-reset-header">
                                    <div>
                                        <strong>비밀번호 초기화</strong>
                                        <span>지정된 관리자 계정으로만 사용할 수 있는 보안 작업입니다.</span>
                                    </div>
                                    <div class="site-password-reset-actions">
                                        <input type="button" onclick="viewpassinit();" id="btnpassinitview" class="site-button site-button-secondary" value="초기화 열기" />
                                        <input type="button" onclick="viewpassinitclose();" id="btnpassinitclose" class="displaynone site-button site-button-secondary" style="display:none;" value="초기화 닫기" />
                                    </div>
                                </div>
                                <div id="tbpassinit" class="displaynone site-password-panel" style="display:none;">
                                    <div class="site-password-grid">
                                        <asp:TextBox ID="txtNewPWD" runat="server" CssClass="ui-input" aria-describedby="button-addon3" TextMode="Password" placeholder="새 비밀번호"></asp:TextBox>
                                        <asp:TextBox ID="txtNewPWD2" runat="server" CssClass="ui-input" aria-describedby="button-addon3" TextMode="Password" placeholder="새 비밀번호 확인"></asp:TextBox>
                                        <asp:Button ID="btnPasswordInitSet" runat="server" Text="비밀번호 초기화" CssClass="site-button site-button-dark" OnClientClick="return ConfirmPassInit();" OnClick="btnPasswordInitSet_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="divButtons" class="site-admin-actions site-member-actions">
                            <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="site-button site-button-primary" OnClick="btnSave_Click"
                                OnClientClick="return uConfirm_member();" />
                            <asp:Button ID="btnDel" runat="server" Text="삭제" CssClass="site-button site-button-danger" OnClientClick="return uConfirmDel_group();"
                                OnClick="btnDel_Click" />
                            <a id="btnList" runat="server" href="/manage/members" class="site-button site-button-list">목록</a>
                        </div>

                        <asp:HiddenField ID="hdBelong" runat="server" />
                        <asp:HiddenField ID="hdUserType" runat="server" />
                        <asp:HiddenField ID="hdStatus" runat="server" />

                        <asp:HiddenField ID="hdBelongNm" runat="server" />
                        <asp:HiddenField ID="hdUserTypeNm" runat="server" />
                        <asp:HiddenField ID="hdStatusNm" runat="server" />

                        <asp:HiddenField ID="hdID" runat="server" />
                        <asp:HiddenField ID="hdKorNm" runat="server" />
                        <asp:HiddenField ID="hdEmail" runat="server" />
            </div>
        </div>
    </div>

</asp:Content>
