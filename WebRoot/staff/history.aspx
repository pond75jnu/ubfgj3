<%@ Page Title="역대 실무자" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="history.aspx.cs" Inherits="staff_history" %>
<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="/common/css/staff-history.css?v=2" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="mx-auto w-full max-w-[1440px] px-4 py-6 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[340px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="history-page min-w-0 rounded-[18px] border border-hairline bg-white p-4 sm:p-6">
                <h1 class="text-[21px] font-semibold text-ink">역대 실무자</h1>
                <hr class="my-4 border-0 border-t border-hairline" />
                <div class="site-admin-filterbar history-filters">
                    <div>
                        <asp:Label runat="server" AssociatedControlID="ddlYear" Text="연도" />
                        <asp:DropDownList ID="ddlYear" runat="server" CssClass="ui-select site-admin-select" AutoPostBack="true" OnSelectedIndexChanged="YearChanged" />
                    </div>
                    <div>
                        <asp:Label runat="server" AssociatedControlID="ddlRetreat" Text="수양회" />
                        <asp:DropDownList ID="ddlRetreat" runat="server" CssClass="ui-select site-admin-select" AutoPostBack="true" OnSelectedIndexChanged="RetreatChanged" />
                    </div>
                </div>
                <asp:Label ID="lblMessage" runat="server" CssClass="history-message" role="status" aria-live="polite" />
                <div class="mt-6">
                    <p class="mb-3 text-sm font-semibold text-[#333333]">
                        목록 (최근 수양회순) · <asp:Literal ID="litCount" runat="server" Mode="Encode" />
                    </p>
                    <p class="history-scroll-hint">표가 화면보다 넓으면 좌우로 밀어 확인하세요.</p>
                    <div class="overflow-x-auto rounded-[18px] border border-hairline bg-white history-table-scroll" tabindex="0" role="region" aria-label="역대 실무자 목록">
                        <asp:GridView ID="gvList" runat="server" DataKeyNames="seq" AllowPaging="true" PageSize="15"
                            AutoGenerateColumns="false" ShowHeader="true" ShowHeaderWhenEmpty="true" UseAccessibleHeader="true"
                            BorderColor="#e0e0e0" CssClass="history-table min-w-full divide-y divide-hairline text-sm text-ink"
                            OnPageIndexChanging="PageChanged">
                            <HeaderStyle CssClass="whitespace-nowrap bg-parchment text-center text-xs font-semibold text-ink" />
                            <Columns>
                                <asp:TemplateField HeaderText="연번">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                </asp:TemplateField>
                                <asp:BoundField DataField="retreat_year" HeaderText="연도" HtmlEncode="true">
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                </asp:BoundField>
                                <asp:BoundField DataField="retreat_name" HeaderText="수양회" HtmlEncode="true">
                                    <ItemStyle CssClass="px-4 py-3" />
                                </asp:BoundField>
                                <asp:TemplateField HeaderText="기간">
                                    <ItemTemplate><%#: Eval("start_date") %><br />~ <%#: Eval("end_date") %></ItemTemplate>
                                    <ItemStyle CssClass="whitespace-nowrap px-4 py-3 text-center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="실무자">
                                    <ItemTemplate><%#: Display(Eval("staff_names")) %></ItemTemplate>
                                    <ItemStyle CssClass="px-4 py-3" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="실무통장">
                                    <ItemTemplate><%#: Display(Eval("bank_info")) %></ItemTemplate>
                                    <ItemStyle CssClass="px-4 py-3" />
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>등록된 수양회가 없습니다.</EmptyDataTemplate>
                            <EmptyDataRowStyle CssClass="px-4 py-6 text-center" />
                            <PagerSettings Mode="NumericFirstLast" PageButtonCount="5" FirstPageText="처음" LastPageText="마지막" Position="Bottom" />
                            <PagerStyle CssClass="history-pager" HorizontalAlign="Center" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
