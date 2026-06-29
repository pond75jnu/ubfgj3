<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="retreatdues.aspx.cs" Inherits="staff_retreatdues" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="mx-auto w-full max-w-[1440px] px-4 py-6 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[280px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="min-w-0 rounded-[18px] border border-hairline bg-white p-4 sm:p-6">
                <h5 class="text-[21px] font-semibold text-ink"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h5>
                <hr class="my-4 border-0 border-t border-hairline" />
                <div class="site-admin-filterbar flex flex-col gap-3 sm:flex-row sm:items-center">
                    <div class="w-full sm:w-auto">
                        <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="block h-11 w-full min-w-[220px] rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                </div>
                <div id="divList" runat="server" class="mt-6">
                    <div class="mb-3 text-sm font-semibold text-[#333333]">
                        목록 (회비구분 가나다 순)
                    </div>
                    <div class="overflow-x-auto rounded-[18px] border border-hairline bg-white">
                        <asp:GridView ID="gvList" runat="server" DataKeyNames="seq" AllowPaging="false" BorderColor="#e0e0e0" CssClass="min-w-full divide-y divide-hairline text-sm text-ink"
                            ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="NUM" HeaderText="연번">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>
                                <asp:BoundField DataField="seq" HeaderText="seq">
                                    <ItemStyle CssClass="hidden" />
                                    <HeaderStyle CssClass="hidden" />
                                </asp:BoundField>
                                <asp:BoundField DataField="dues_nm" HeaderText="회비구분">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>
                                <asp:BoundField DataField="dues_format" HeaderText="회비">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>
                                <asp:BoundField DataField="dues_desc" HeaderText="비고">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>

                            </Columns>
                            <EmptyDataTemplate>
                                <table class="min-w-full text-sm text-ink">
                                    <tr>
                                        <td class="px-4 py-6 text-center text-[#7a7a7a]" style="border: 0px none #ffffff;">등록된 수양회비구분 정보가 없습니다.
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
                        <span class="site-entry-form-subtitle">회비 구분 정보</span>
                    </div>
                    <div class="site-entry-form-card">
                        <div class="grid">
                            <div>
                                <label>회비구분명</label><span class="site-required-mark">필수</span>
                            </div>
                            <div>
                                <asp:TextBox ID="txtRetreatDuesNM" runat="server" CssClass="ui-input"></asp:TextBox>
                            </div>
                        </div>
                        <div class="grid">
                            <div>
                                <label>회비</label><span class="site-required-mark">필수</span>
                            </div>
                            <div>
                                <asp:TextBox ID="txtRetreatDues" runat="server" CssClass="ui-input" onkeyup="inputNumberFormat(this);" autocomplete="off"></asp:TextBox>
                            </div>
                        </div>
                        <div class="grid">
                            <div>
                                <label>비고</label>
                            </div>
                            <div>
                                <asp:TextBox ID="txtRetreatDuesDesc" runat="server" CssClass="ui-input"></asp:TextBox>
                            </div>
                        </div>
                        <div id="divSaveAlert" runat="server" visible="false" class="site-form-error">
                            <asp:Label id="lblAlert" runat="server" ForeColor="Red"></asp:Label>
                        </div>
                    </div>
                </div>
                <div id="divButtons" class="mt-6 flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                    <a id="btnNew" runat="server" href="/staff/retreatdues?mode=write" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white no-underline transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">신규
                    </a>
                    <input type="button" id="btnModify" runat="server" onclick="modify_retreat();" value="수정" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" />
                    <a id="btnList" runat="server" href="/staff/retreatdues" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action no-underline transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">목록
                    </a>
                    <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" OnClick="btnSave_Click"
                        OnClientClick="return uConfirm_retreatdues();" />
                    <asp:Button ID="btnDel" runat="server" Text="삭제" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill border border-[#f1b8b2] bg-white px-[22px] py-[11px] text-[17px] font-normal text-[#b42318] transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" OnClientClick="return uConfirmDel_retreatdues();"
                        OnClick="btnDel_Click" />
                </div>

                <asp:HiddenField ID="hdRetreatDuesNM" runat="server" />
                <asp:HiddenField ID="hdRetreatDues" runat="server" />
                <asp:HiddenField ID="hdRetreatDuesDesc" runat="server" />
                <asp:HiddenField ID="hdRetreat" runat="server" />
                <asp:HiddenField ID="hdSeq" runat="server" />
                <asp:HiddenField ID="hdMode" runat="server" />
                <asp:HiddenField ID="hdPageMode" runat="server" />
            </div>
        </div>
    </div>
</asp:Content>
