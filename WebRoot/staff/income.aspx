<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="income.aspx.cs" Inherits="staff_income" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script>
        window.onload = function () {
            $(".datepicker").datepicker();
            attatch_file_expenses_init();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="mx-auto w-full max-w-[1440px] px-4 pb-12 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-[340px_minmax(0,1fr)]">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="min-w-0 space-y-6">
                <div class="border-b border-hairline pb-4">
                    <h1 class="text-[28px] font-semibold leading-tight text-ink">
                        <asp:Label ID="lblPageTitle" runat="server"></asp:Label>
                    </h1>
                </div>
                <div class="site-admin-filterbar grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
                    <div>
                        <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus disabled:bg-parchment disabled:text-[#7a7a7a]" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                </div>
                <div id="divList" runat="server" class="space-y-3">
                    <div class="text-sm font-semibold text-[#7a7a7a]">
                        목록 (수입일자 순)
                    </div>
                    <div class="text-right text-[17px] font-semibold text-ink">
                        <asp:Label ID="lblSum" runat="server" Font-Bold="true"></asp:Label>
                    </div>
                    <div class="overflow-x-auto rounded-apple-lg border border-hairline bg-white">
                        <asp:GridView ID="gvList" runat="server" DataKeyNames="seq" AllowPaging="false" BorderColor="#dee2e6" CssClass="min-w-[920px] w-full border-collapse text-sm text-ink [&_td]:border-b [&_td]:border-hairline [&_td]:px-4 [&_td]:py-3 [&_th]:border-b [&_th]:border-hairline [&_th]:bg-parchment [&_th]:px-4 [&_th]:py-3 [&_th]:font-semibold"
                            ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="NUM" HeaderText="연번">
                                    <ItemStyle CssClass="txt_center nowrap" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="seq" HeaderText="seq">
                                    <ItemStyle CssClass="displaynone" />
                                    <HeaderStyle CssClass="displaynone" />
                                </asp:BoundField>
                                <asp:BoundField DataField="payment_type_nm" HeaderText="수입항목">
                                    <ItemStyle CssClass="nowrap" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="payment_item" HeaderText="수입내용">
                                    <ItemStyle CssClass="nowrap" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="payment_format" HeaderText="수입금액">
                                    <ItemStyle CssClass="nowrap txt_right" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="payment_dt" HeaderText="수입일자">
                                    <ItemStyle CssClass="nowrap txt_center" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="attatch_yn" HeaderText="증빙자료">
                                    <ItemStyle CssClass="txt_center nowrap" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>
                                <asp:BoundField DataField="payment_item_desc" HeaderText="비고">
                                    <ItemStyle CssClass="nowrap" />
                                    <HeaderStyle CssClass="txt_center nowrap" />
                                </asp:BoundField>

                            </Columns>
                            <EmptyDataTemplate>
                                <table class="w-full text-sm text-ink">
                                    <tr>
                                        <td class="px-4 py-6" style="border: 0px none #ffffff;">등록된 수입정보가 없습니다.
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div id="divWriteModify" runat="server" class="site-entry-form-section">

                    <div class="site-entry-form-title text-sm font-semibold text-[#7a7a7a]">
                        <asp:Label ID="lblWriteModeTitle" CssClass="site-entry-form-title-text text-sm font-semibold text-[#7a7a7a]" runat="server"></asp:Label>
                    </div>
                    <div class="site-entry-form-card space-y-4 rounded-apple-lg border border-hairline bg-white p-5">
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-center">
                            <div class="text-sm font-semibold text-ink">
                                수입항목
                            </div>
                            <div class="min-w-0">
                                <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                                    <div class="min-w-0">
                                        <asp:DropDownList ID="ddl_cash_item" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 pr-10 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" DataValueField="seq" DataTextField="item_nm"></asp:DropDownList>
                                    </div>
                                    <div class="hidden md:block">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-center">
                            <div class="text-sm font-semibold text-ink">
                                수입내용
                            </div>
                            <div class="min-w-0">
                                <asp:TextBox ID="txtPaymentNM" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" autocomplete="off"></asp:TextBox>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-center">
                            <div class="text-sm font-semibold text-ink">
                                수입금액
                            </div>
                            <div class="min-w-0">
                                <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                                    <div class="min-w-0">
                                        <asp:TextBox ID="txtPayment" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" onkeyup="inputNumberFormat(this);" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="hidden md:block">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-center">
                            <div class="text-sm font-semibold text-ink">
                                수입일자
                            </div>
                            <div class="min-w-0">
                                <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                                    <div class="min-w-0">
                                        <asp:TextBox ID="txtPaymentDT" runat="server" CssClass="datepicker block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="hidden md:block">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-start">
                            <div class="text-sm font-semibold text-ink md:pt-3">
                                증빙(이미지)
                            </div>
                            <div class="min-w-0">
                                <asp:FileUpload ID="imgUpload" runat="server" CssClass="block w-full rounded-apple-lg border border-black/10 bg-white px-5 py-3 text-[15px] text-ink file:mr-4 file:rounded-pill file:border-0 file:bg-parchment file:px-4 file:py-2 file:text-sm file:text-ink focus:outline-none focus:ring-2 focus:ring-action-focus" />
                                <div id="divAttatchImageDelete" runat="server" visible="false" class="pt-3 text-sm leading-6 text-[#7a7a7a]">                                    
                                    <asp:CheckBox ID="chkAttDel01" Text="&nbsp;delete" runat="server" />
                                </div>
                                <div id="divAttatchImage" runat="server" visible="false" class="space-y-3 pt-3">                                    
                                    <asp:Image ID="AttatchImage" runat="server" CssClass="h-auto max-w-full rounded-apple-sm border border-hairline attatch_image01" AlternateText="증빙" />
                                    <div class="flex flex-wrap gap-2">
                                        <input type="button" value="다운로드" class="inline-flex min-h-10 items-center justify-center rounded-apple-sm bg-ink px-[15px] py-2 text-sm font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" onclick="downloadImg();" />
                                        <a href="javascript:;" class="inline-flex min-h-10 items-center justify-center rounded-apple-sm border border-hairline bg-white px-[15px] py-2 text-sm font-normal text-ink transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" id="aAttatchImage" runat="server" target="_blank">원본보기</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 gap-2 md:grid-cols-[160px_minmax(0,1fr)] md:items-center">
                            <div class="text-sm font-semibold text-ink">
                                비고
                            </div>
                            <div class="min-w-0">
                                <asp:TextBox ID="txtPaymentDesc" runat="server" CssClass="block h-11 w-full rounded-pill border border-black/10 bg-white px-5 text-[17px] text-ink focus:border-action-focus focus:outline-none focus:ring-2 focus:ring-action-focus" autocomplete="off"></asp:TextBox>
                            </div>
                        </div>
                        <div id="divSaveAlert" class="rounded-apple-lg border border-hairline bg-parchment p-4 text-sm" runat="server" visible="false">
                            <asp:Label ID="lblAlert" runat="server" ForeColor="Red"></asp:Label>
                        </div>
                    </div>
                </div>
                <div id="divButtons" class="flex flex-wrap gap-2">
                    <a id="btnNew" runat="server" href="/staff/income?mode=write" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">신규
                    </a>
                    <input type="button" id="btnModify" runat="server" onclick="modify_income();" value="수정" class="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus" />
                    <asp:Button ID="btnSave" runat="server" Text="저장" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill bg-action px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus disabled:cursor-not-allowed disabled:bg-[#7a7a7a]" OnClick="btnSave_Click"
                        OnClientClick="return uConfirm_income();" />
                    <asp:Button ID="btnDel" runat="server" Text="삭제" CssClass="inline-flex min-h-11 items-center justify-center rounded-pill border border-[#b42318] bg-[#b42318] px-[22px] py-[11px] text-[17px] font-normal text-white transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus disabled:cursor-not-allowed disabled:border-[#f1b8b2] disabled:bg-[#fef3f2] disabled:text-[#b42318]" OnClientClick="return uConfirmDel_income();"
                        OnClick="btnDel_Click" />
                    <a id="btnList" runat="server" href="/staff/income" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">목록
                    </a>
                    <a id="btnExportExcel" runat="server" href="javascript:;" onclick="income_list_excel();" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">
                        엑셀저장
                    </a>
                    <a id="btnPrintDetail" runat="server" href="javascript:;" onclick="income_detail_print();" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">
                        인쇄
                    </a>
                    <a id="btnPrintAll" runat="server" href="javascript:;" onclick="income_all_print();" class="inline-flex min-h-11 items-center justify-center rounded-pill border border-action bg-white px-[22px] py-[11px] text-[17px] font-normal text-action transition active:scale-95 focus:outline-none focus:ring-2 focus:ring-action-focus">
                        전체 수입현황 인쇄
                    </a>
                </div>

                <asp:HiddenField ID="hdCashCode" runat="server" />
                <asp:HiddenField ID="hdExpensesNM" runat="server" />
                <asp:HiddenField ID="hdExpenses" runat="server" />
                <asp:HiddenField ID="hdExpensesDT" runat="server" />
                <asp:HiddenField ID="hdExpensesDesc" runat="server" />
                <asp:HiddenField ID="hdRetreat" runat="server" />
                <asp:HiddenField ID="hdSeq" runat="server" />

                <asp:HiddenField ID="hdImgUrl" runat="server" />
                <asp:HiddenField ID="hdImgPath" runat="server" />
                <asp:HiddenField ID="hdImgPath_Temp" runat="server" />
            </div>
            <div class="displaynone">
                <iframe id="ifrSelfReportExcel"></iframe>
            </div>
        </div>
    </div>
</asp:Content>

