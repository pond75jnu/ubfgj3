<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="groups.aspx.cs" Inherits="manage_groups" %>

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
                        <div class="site-admin-filterbar flex flex-col gap-3 sm:flex-row sm:items-center">
                            <div class="w-full sm:w-auto">
                                <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="ui-select site-admin-select" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged" Enabled="false"></asp:DropDownList>
                            </div>
                        </div>
                        <div id="divList" runat="server" class="mt-6">
                            <div class="mb-3 text-sm font-semibold text-[#333333]">

                                목록(요회명 가나다 순) 
                            </div>
                            <div class="overflow-x-auto rounded-[18px] border border-hairline bg-white">
                                <asp:GridView ID="gvList" runat="server" DataKeyNames="seq" AllowPaging="false" BorderColor="#e0e0e0" CssClass="min-w-full divide-y divide-hairline text-sm text-ink"
                                    ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                                    <Columns>
                                        <asp:BoundField DataField="num" HeaderText="연번">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="seq" HeaderText="seq">
                                            <ItemStyle CssClass="hidden" />
                                            <HeaderStyle CssClass="hidden" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="belong_nm" HeaderText="요회">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="manager" HeaderText="요회목자">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="use_yn" HeaderText="사용여부">
                                            <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                        </asp:BoundField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <table class="min-w-full text-sm text-ink">
                                            <tr>
                                                <td class="px-4 py-6 text-center text-[#7a7a7a]" style="border: 0px none #ffffff;">등록된 요회가 없습니다.
                                                </td>
                                            </tr>
                                        </table>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                        <div id="divWriteModify" runat="server" class="site-entry-form-section">
                            <div class="site-entry-form-title">
                                <asp:Label ID="lblWriteModeTitle" CssClass="site-entry-form-title-text" runat="server"></asp:Label>
                                <span class="site-entry-form-subtitle">요회 기본 정보</span>
                            </div>
                            <div class="site-entry-form-card site-manage-form-card">
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_txtBelong">요회명</label>
                                        <span class="site-required-mark">필수</span>
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtBelong" runat="server" CssClass="ui-input"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_txtManager">요회목자</label>
                                        <span class="site-required-mark">필수</span>
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtManager" runat="server" CssClass="ui-input"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="grid">
                                    <div>
                                        <label for="ContentPlaceHolder1_ddl_use_yn">사용여부</label>
                                    </div>
                                    <div>
                                        <asp:DropDownList ID="ddl_use_yn" runat="server" CssClass="ui-select">
                                            <asp:ListItem Value="Y">사용</asp:ListItem>
                                            <asp:ListItem Value="N">미사용</asp:ListItem>
                                        </asp:DropDownList>
                                        <p class="site-form-help">미사용으로 변경하면 선택 목록과 관리 흐름에서 제외됩니다.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="divButtons" class="site-admin-actions">
                            <a id="btnNew" runat="server" href="/manage/groups?mode=write" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white no-underline transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">신규
                            </a>
                            <input type="button" id="btnModify" runat="server" onclick="modify_group();" value="수정" class="site-button site-button-primary" />
                            <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="site-button site-button-primary site-group-action-button" OnClick="btnSave_Click"
                                OnClientClick="return uConfirm_group();" />
                            <asp:Button ID="btnDel" runat="server" Text="삭제" CssClass="site-button site-button-danger site-group-action-button" OnClientClick="return uConfirmDel_group();"
                                OnClick="btnDel_Click" />
                            <a id="btnList" runat="server" href="/manage/groups" class="site-button site-button-list site-group-action-button">목록</a>
                        </div>

                        <asp:HiddenField ID="hdBelong" runat="server" />
                        <asp:HiddenField ID="hdManager" runat="server" />
                        <asp:HiddenField ID="hdUseYN" runat="server" />
                        <asp:HiddenField ID="hdSeq" runat="server" />
                        <asp:HiddenField ID="hdMode" runat="server" />
                        <asp:HiddenField ID="hdPageMode" runat="server" />
            </div>
        </div>
    </div>


</asp:Content>
