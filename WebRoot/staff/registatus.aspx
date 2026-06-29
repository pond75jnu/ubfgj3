<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="registatus.aspx.cs" Inherits="staff_registatus" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .my-custom-scrollbar {
            position: relative;
            height: 670px;
            overflow: auto;
        }

        .table-wrapper-scroll-y {
            display: block;
        }
    </style>
    <script>
        window.onload = function () {
            manager_confirm_select();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="mx-auto w-full max-w-[1440px] px-4 pb-12 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[280px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="min-w-0 space-y-6">
                <div class="border-b border-hairline pb-4">
                    <h1 class="text-[28px] font-semibold leading-tight text-ink">
                        <asp:Label ID="lblPageTitle" runat="server"></asp:Label>
                    </h1>
                </div>
                <div class="site-admin-control-card">
                    <div class="site-admin-filterbar grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
                        <div>
                            <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus disabled:bg-parchment disabled:text-[#7a7a7a]" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div>
                            <asp:DropDownList ID="ddl_group" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" DataValueField="seq" DataTextField="belong_nm" AutoPostBack="true" OnSelectedIndexChanged="ddl_group_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div>
                            <asp:DropDownList ID="ddl_regi_type" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" AutoPostBack="true" OnSelectedIndexChanged="ddl_regi_type_SelectedIndexChanged">
                                <asp:ListItem Value="%">== 전체 (등록여부) ==</asp:ListItem>
                                <asp:ListItem Value="1">완전등록</asp:ListItem>
                                <asp:ListItem Value="2">부분등록</asp:ListItem>
                                <asp:ListItem Value="3">미등록</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="site-admin-help">
                        <ul>
                            <li>이름, 납부금액, 방법 등이 확인된 분은 확인란의 체크박스를 '체크' 후 [저장]하시기 바랍니다.
                            </li>
                            <li>'체크해제' 후 저장 시 실무자 확인이 '취소' 됩니다. 
                            </li>
                            <li>'실무자 확인' 처리했으나 요회담당자가 금액, 이름 등을 수정할 경우 재확인 란에 'Y'가 표시됩니다.
                            </li>
                        </ul>
                    </div>
                    <div id="divDuesInfo" runat="server" class="site-dues-info">
                    </div>
                </div>
                <div class="site-regist-summary-host">
                    <section class="site-regist-summary" aria-label="등록비 요약">
                        <div id="divRegistFeeSummary" runat="server" class="site-regist-summary-content">
                        </div>
                        <div class="site-regist-summary-actions">
                            <asp:Button ID="btnSave" runat="server" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus disabled:cursor-not-allowed disabled:bg-[#7a7a7a]" Text="저장 (실무확인)" OnClientClick="return manage_confirm_save();" OnClick="btnSave_Click" />
                            <asp:Button ID="btnExcel" runat="server" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus disabled:cursor-not-allowed disabled:border-hairline disabled:text-[#7a7a7a]" Text="엑셀저장" OnClientClick="excel_export()" />
                        </div>
                    </section>
                </div>
                <div class="table-wrapper-scroll-y my-custom-scrollbar rounded-apple-lg border border-hairline bg-white">
                    <asp:ListView runat="server" ID="lvItems" DataKeyNames="seq"
                        OnItemDataBound="listView_ItemDataBound">
                        <LayoutTemplate>
                            <table id="ListViewTable" class="min-w-[980px] w-full divide-y divide-hairline text-sm text-ink [&_td]:border-b [&_td]:border-hairline [&_td]:px-4 [&_td]:py-3 [&_th]:bg-parchment [&_th]:px-4 [&_th]:py-3 [&_th]:font-semibold">
                                <thead>
                                    <tr>
                                        <th class="nowrap txt_center">연번
                                        </th>
                                        <th class="nowrap txt_center">요회
                                        </th>
                                        <th class="nowrap txt_center">이름
                                        </th>
                                        <th class="nowrap txt_center">회원구분
                                        </th>
                                        <th class="nowrap txt_center">회비구분
                                        </th>
                                        <th class="nowrap txt_center">납부한금액
                                        </th>
                                        <th class="nowrap txt_center">납부방법
                                        </th>
                                        <th class="nowrap txt_center">등록여부
                                        </th>
                                        <th class="nowrap txt_center">
                                            <a href="javascript:;" class="displaynone" onclick="selectAllChkFunc();">실무확인</a>
                                            <asp:CheckBox ID="chkHeader" CssClass="selectAllChk" Text="&nbsp;확인" runat="server" />
                                        </th>
                                        <th class="displaynone"></th>
                                        <th class="displaynone"></th>
                                        <th class="displaynone"></th>
                                        <th class="displaynone"></th>
                                        <th class="nowrap txt_center">재확인
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr runat="server" id="itemPlaceHolder" />
                                </tbody>
                            </table>
                        </LayoutTemplate>
                        <ItemTemplate>
                            <tr runat="server" id="itemPlaceHolder" style="background-color: #ffffff;">
                                <td class="nowrap txt_center">
                                    <%# Eval("NUM") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("belong_nm") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("user_nm") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("usertype_nm") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("dues_nm") %>
                                </td>
                                <td class="nowrap txt_right">
                                    <%# Eval("user_dues_won") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("howto_regist_nm") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("regi_status_nm") %>
                                </td>
                                <td class="nowrap txt_center">
                                    <asp:CheckBox ID="chkBox1" CssClass="selectOneChk" runat="server" />
                                    <asp:Label ID="lblNocheck" runat="server"></asp:Label>
                                </td>
                                <td class="displaynone">
                                    <%# Eval("checkbox_visible") %>
                                </td>
                                <td class="displaynone">
                                    <%# Eval("manager_confirm") %>
                                </td>
                                <td class="displaynone">
                                    <%# Eval("etc_confirm") %>
                                </td>
                                <td class="displaynone">
                                    <asp:Label ID="lblUptYN" Text='<%# Eval("checkbox_visible") %>' runat="server"></asp:Label>
                                    <asp:Label ID="lblSeq" Text='<%# Eval("seq") %>' runat="server"></asp:Label>
                                </td>
                                <td class="nowrap txt_center">
                                    <%# Eval("etc_notice") %>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <table class="w-full border-collapse text-sm text-ink">
                                <tr>
                                    <td class="p-8 txt_center" style="background-color: #ffffff;">조회 결과 없음
                                    </td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                    </asp:ListView>
                    <%-- <div class="PagerLayOut">
                        <asp:DataPager ID="listPager" runat="server" PageSize="15" PagedControlID="lvItems">
                            <Fields>
                                <asp:NextPreviousPagerField ButtonCssClass="PagerNextL" ButtonType="Image" FirstPageImageUrl="/Common/images/pager/pagepre_end.gif"
                                    ShowFirstPageButton="True" ShowNextPageButton="False" PreviousPageImageUrl="/Common/images/pager/pagepre.gif" />
                                <asp:NumericPagerField CurrentPageLabelCssClass="PagerCurrent" NumericButtonCssClass="PagerNormal"
                                    ButtonCount="5" NextPageText="" PreviousPageText="" RenderNonBreakingSpacesBetweenControls="False" />
                                <asp:NextPreviousPagerField ButtonCssClass="PagerNextR" ButtonType="Image" LastPageImageUrl="/Common/images/pager/pagenext_end.gif"
                                    NextPageImageUrl="/Common/images/pager/pagenext.gif"
                                    ShowLastPageButton="True" ShowPreviousPageButton="False" />
                            </Fields>
                        </asp:DataPager>
                    </div> --%>
                </div>
            </div>
        </div>
    </div>
    <div class="displaynone">
        <iframe id="ifrSelfReportExcel"></iframe>
    </div>
</asp:Content>

