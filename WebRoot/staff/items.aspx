<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="items.aspx.cs" Inherits="staff_items" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="mx-auto w-full max-w-[1440px] px-4 py-6 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[340px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="min-w-0 rounded-[18px] border border-hairline bg-white p-4 sm:p-6">
                <h5 class="text-[21px] font-semibold text-ink"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h5>
                <hr class="my-4 border-0 border-t border-hairline" />
                <div class="site-admin-filterbar flex flex-col gap-3 sm:flex-row sm:items-center" id="divGubun" runat="server">
                    <div class="w-full sm:w-auto">
                        <asp:DropDownList ID="ddl_code_type" runat="server" CssClass="block h-11 w-full min-w-[220px] rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" AutoPostBack="true" OnSelectedIndexChanged="ddl_code_type_SelectedIndexChanged">
                            <asp:ListItem Value="%">== 전체 (코드구분) ==</asp:ListItem>
                            <asp:ListItem Value="1">수입코드</asp:ListItem>
                            <asp:ListItem Value="2">지출코드</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div id="divList" runat="server" class="mt-6">
                    <div class="mb-3 text-sm font-semibold text-[#333333]">
                        목록 (코드값 순)
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
                                <asp:BoundField DataField="cash_type_nm" HeaderText="코드구분">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>
                                <asp:BoundField DataField="item_nm" HeaderText="코드명">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>
                                <asp:BoundField DataField="seq" HeaderText="코드값">
                                    <ItemStyle CssClass="hidden" />
                                    <HeaderStyle CssClass="hidden" />
                                </asp:BoundField>
                                <asp:BoundField DataField="item_desc" HeaderText="비고">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3" />
                                    <HeaderStyle CssClass="whitespace-nowrap bg-parchment px-4 py-3 text-center text-xs font-semibold text-ink" />
                                </asp:BoundField>

                            </Columns>
                            <EmptyDataTemplate>
                                <table class="min-w-full text-sm text-ink">
                                    <tr>
                                        <td class="px-4 py-6 text-center text-[#7a7a7a]" style="border: 0px none #ffffff;">등록된 코드값이 없습니다.
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div id="divWriteModify" runat="server" class="mt-6">
                    <div class="mb-3 text-sm font-semibold text-[#333333]">
                        <asp:Label ID="lblWriteModeTitle" CssClass="text-sm font-semibold text-[#333333]" runat="server"></asp:Label>
                    </div>
                    <div class="overflow-x-auto rounded-[18px] border border-hairline bg-white">
                        <table class="min-w-full divide-y divide-hairline text-sm text-ink">                            
                            <tr>
                                <th class="w-36 whitespace-nowrap bg-parchment px-4 py-3 text-left font-semibold text-ink">코드구분
                                </th>
                                <td class="min-w-[260px] px-4 py-3">
                                    <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                                        <div>
                                            <asp:DropDownList ID="ddl_code_type_write" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" AutoPostBack="true">                                        
                                                <asp:ListItem Value="1">수입코드</asp:ListItem>
                                                <asp:ListItem Value="2">지출코드</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr class="hidden">
                                <th class="w-36 whitespace-nowrap bg-parchment px-4 py-3 text-left font-semibold text-ink">코드값
                                </th>
                                <td class="min-w-[260px] px-4 py-3">
                                    <asp:Label ID="lblCode" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <th class="w-36 whitespace-nowrap bg-parchment px-4 py-3 text-left font-semibold text-ink">코드명
                                </th>
                                <td class="min-w-[260px] px-4 py-3">
                                    <asp:TextBox ID="txtCodeNM" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <th class="w-36 whitespace-nowrap bg-parchment px-4 py-3 text-left font-semibold text-ink">비고
                                </th>
                                <td class="min-w-[260px] px-4 py-3">
                                    <asp:TextBox ID="txtItemDesc" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus"></asp:TextBox>
                                </td>
                            </tr>                                                        
                        </table>
                        <div id="divSaveAlert" runat="server" visible="false" class="px-4 pb-5 text-sm text-[#b42318]">
                            <asp:Label id="lblAlert" runat="server" ForeColor="Red"></asp:Label>
                        </div>
                    </div>
                </div>
                <div id="divButtons" class="mt-6 flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                    <a id="btnNew" runat="server" href="javascript:;" onclick="go_item_new();" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white no-underline transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">신규
                    </a>
                    <input type="button" id="btnModify" runat="server" onclick="modify_retreat();" value="수정" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" />
                    <a id="btnList" runat="server" href="javascript:;" onclick="go_item_list();" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action no-underline transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">목록
                    </a>
                    <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" OnClick="btnSave_Click"
                        OnClientClick="return uConfirm_item();" />
                    <asp:Button ID="btnDel" runat="server" Text="삭제" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill border border-[#f1b8b2] bg-white px-[22px] py-[11px] text-[17px] font-normal text-[#b42318] transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" OnClientClick="return uConfirmDel_retreatdues();"
                        OnClick="btnDel_Click" />
                </div>

                
                <asp:HiddenField ID="hdRetreat" runat="server" />
                <asp:HiddenField ID="hdSeq" runat="server" />
            </div>
        </div>
    </div>
</asp:Content>

