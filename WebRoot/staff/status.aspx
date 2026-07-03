<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="status.aspx.cs" Inherits="staff_status" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .site-status-page {
            padding: 0 0 64px;
        }

        .site-status-page .site-layout-row {
            grid-template-columns: 340px minmax(0, 1fr);
            gap: 0;
        }

        .site-status-page .site-layout-row > .site-sidebar {
            width: 340px;
            padding-left: 10px;
            padding-right: 10px;
        }

        .site-status-main {
            padding: 0 48px 0 32px;
        }

        .site-status-control-card {
            overflow: hidden;
            margin-bottom: 12px;
            border: 1px solid #d8dee8;
            border-radius: 8px;
            background: #fff;
        }

        .site-status-filterbar {
            gap: 10px;
            margin: 0;
            border: 0;
            border-radius: 0;
            background: transparent;
            padding: 12px 14px;
        }

        .site-status-filterbar > * {
            min-width: 0;
        }

        .site-status-filterbar .ui-select {
            width: 260px;
            min-height: 32px !important;
            height: 32px !important;
            border-radius: 4px !important;
            padding: 5px 30px 5px 10px !important;
            font-size: 13px !important;
            font-weight: 700;
            line-height: 1.25 !important;
        }

        .site-status-tabs {
            border-top: 1px solid #e6eaf1;
            padding: 10px 12px 6px;
        }

        .site-status-tabs .site-tabs {
            display: inline-flex;
            flex-wrap: wrap;
            gap: 4px;
            margin: 0;
            border: 1px solid #d8dee8;
            border-radius: 8px;
            background: #f8fafc;
            padding: 3px;
            list-style: none;
        }

        .site-status-tabs .site-tab-link {
            min-height: 32px;
            border: 0;
            border-radius: 4px;
            padding: 0 12px;
            color: #4b5563;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.2;
        }

        .site-status-tabs .site-tab-link:hover {
            background: #fff;
            color: #0066cc;
        }

        .site-status-tabs .site-tab-link.is-active {
            background: #111827;
            color: #fff;
            box-shadow: 0 1px 2px rgba(17, 24, 39, 0.12);
        }

        .site-status-content {
            margin-top: 0 !important;
            border-top: 0;
            border-radius: 0;
            background: #fff;
        }

        .site-status-summary-board {
            padding: 6px 14px 14px;
        }

        .site-status-summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, 320px);
            align-items: start;
            gap: 14px;
        }

        .site-status-summary-cell {
            width: 320px;
            min-width: 0;
        }

        .site-status-summary-cell .site-summary-table {
            width: auto;
            min-width: 320px;
            max-width: 320px;
            margin: 0;
            table-layout: auto;
            border-color: #d8dee8;
        }

        .site-status-summary-cell .site-summary-table caption {
            padding: 8px 2px 7px;
            color: #111827;
            font-size: 14px;
            font-weight: 700;
            line-height: 1.2;
            white-space: nowrap;
        }

        .site-status-summary-cell .site-summary-table caption a {
            color: #0057ff;
            text-decoration: none;
        }

        .site-status-summary-cell .site-summary-table caption a:hover {
            color: #003ea8;
            text-decoration: underline;
            text-underline-offset: 2px;
        }

        .site-status-summary-cell .site-summary-table th,
        .site-status-summary-cell .site-summary-table td {
            padding: 5px 2px !important;
            font-size: 12px !important;
            line-height: 1.15 !important;
            white-space: nowrap !important;
        }

        .site-status-summary-cell .site-summary-table thead th {
            background: #111827;
            color: #fff;
            font-size: 11px !important;
            font-weight: 700;
            letter-spacing: 0;
        }

        .site-status-summary-cell .site-summary-table tbody td {
            color: #1d1d1f;
            font-variant-numeric: tabular-nums;
        }

        .site-status-summary-cell .site-summary-table tbody td:first-child {
            font-weight: 700;
        }

        .site-status-payment-board {
            overflow: hidden;
            background: #f8fafc;
            padding: 12px 14px 14px;
        }

        .site-status-payment-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .site-status-payment-section {
            min-width: 0;
            overflow: hidden;
            border: 1px solid #d8dee8;
            border-radius: 8px;
            background: #fff;
        }

        .site-status-payment-section + .site-status-payment-section {
            border-left: 1px solid #d8dee8;
        }

        .site-status-page .site-status-payment-section .site-status-payment-title {
            display: flex;
            align-items: center;
            gap: 7px;
            margin: 0;
            border-bottom: 1px solid #e6eaf1;
            background: #fff;
            color: #111827;
            font-size: 12px !important;
            font-weight: 700;
            line-height: 1.25 !important;
            padding: 10px 12px;
        }

        .site-status-payment-title::before {
            content: "";
            width: 4px;
            height: 14px;
            border-radius: 9999px;
            background: #0057ff;
        }

        .site-status-table-wrap {
            overflow-x: auto;
            border: 0;
            border-radius: 0;
            background: #fff;
        }

        .site-status-pay-table {
            width: 100%;
            min-width: 320px;
            border-collapse: collapse;
            color: #1d1d1f;
            font-size: 12px;
        }

        .site-status-pay-table th,
        .site-status-pay-table td {
            border-bottom: 1px solid #e0e0e0;
            padding: 7px 10px;
            vertical-align: middle;
        }

        .site-status-pay-table th {
            background: #f8fafc;
            color: #111827;
            font-weight: 700;
            text-align: center;
        }

        .site-status-pay-table tr:last-child td {
            border-bottom: 0;
            background: #eef4ff;
            color: #0f172a;
            font-weight: 700;
        }

        .site-status-empty-table {
            width: 100%;
            color: #4b5563;
            font-size: 13px;
        }

        .site-status-empty-table td {
            padding: 18px 12px;
            text-align: center;
        }

        .site-status-result {
            margin-top: 12px;
            border: 1px solid #d8dee8;
            border-radius: 8px;
            background: #fff;
            padding: 10px 12px;
            text-align: center;
        }

        .site-status-result-label {
            font-size: 22px;
            font-weight: 700;
            line-height: 1.2;
        }

        .site-status-page.site-status-mode-2 .site-status-filterbar .ui-select,
        .site-status-page.site-status-mode-2 .site-status-tabs .site-tab-link,
        .site-status-page.site-status-mode-2 .site-status-payment-section .site-status-payment-title,
        .site-status-page.site-status-mode-2 .site-status-pay-table,
        .site-status-page.site-status-mode-2 .site-status-pay-table th,
        .site-status-page.site-status-mode-2 .site-status-pay-table td,
        .site-status-page.site-status-mode-2 .site-status-empty-table,
        .site-status-page.site-status-mode-2 .site-status-empty-table td {
            font-size: 14px !important;
            line-height: 1.35 !important;
        }

        @media (max-width: 1023.98px) {
            .site-status-page {
                padding: 0 24px 40px;
            }

            .site-status-page .site-layout-row {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .site-status-page .site-layout-row > .site-sidebar {
                width: 100%;
                padding-left: 0;
                padding-right: 0;
            }

            .site-status-main {
                padding: 0;
            }
        }

        @media (max-width: 640px) {
            .site-status-page {
                padding: 0 16px 36px;
            }

            .site-status-filterbar .ui-select {
                width: 100%;
            }

            .site-status-tabs .site-tabs {
                display: grid;
                width: 100%;
                grid-template-columns: 1fr;
            }

            .site-status-payment-grid {
                grid-template-columns: 1fr;
            }

            .site-status-payment-section + .site-status-payment-section {
                border-top: 1px solid #e6eaf1;
                border-left: 1px solid #d8dee8;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="divStatusPage" runat="server" class="site-panel site-status-page">
        <div class="site-layout-row">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="site-content-main site-status-main">
                <h1 class="site-page-title"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h1>
                <div class="site-status-control-card">
                    <div class="site-filterbar site-status-filterbar">
                        <div>
                            <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                    </div>
                    <div id="divTab" runat="server" class="site-status-tabs">
                    </div>
                    <div id="divContents" runat="server" class="site-status-content site-status-summary-board" visible="false">
                    </div>
                    <div id="divContents2" runat="server" class="site-status-content site-status-payment-board" visible="false">
                        <div class="site-status-payment-grid">
                            <section class="site-status-payment-section">
                                <h2 class="site-status-payment-title">수입현황</h2>
                                <div class="site-status-table-wrap">
                                    <asp:GridView ID="gvList" runat="server" DataKeyNames="payment_seq" AllowPaging="false" BorderColor="#dee2e6" CssClass="site-status-pay-table"
                                        ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                                        <Columns>

                                            <asp:BoundField DataField="payment_type_nm" HeaderText="수입항목">
                                                <ItemStyle CssClass="nowrap" />
                                                <HeaderStyle CssClass="txt_center nowrap" />
                                            </asp:BoundField>
                                            <asp:BoundField DataField="payment_format" HeaderText="수입금액">
                                                <ItemStyle CssClass="txt_right nowrap" />
                                                <HeaderStyle CssClass="txt_center nowrap" />
                                            </asp:BoundField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <table class="site-status-empty-table">
                                                <tr>
                                                    <td style="border: 0px none #ffffff;">수입금액이 없습니다.
                                                    </td>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </section>
                            <section class="site-status-payment-section">
                                <h2 class="site-status-payment-title">지출현황</h2>
                                <div class="site-status-table-wrap">
                                    <asp:GridView ID="gvList2" runat="server" DataKeyNames="payment_seq" AllowPaging="false" BorderColor="#dee2e6" CssClass="site-status-pay-table"
                                        ShowHeader="true" AutoGenerateColumns="false" OnRowDataBound="gvList2_RowDataBound">
                                        <Columns>

                                            <asp:BoundField DataField="payment_type_nm" HeaderText="지출항목">
                                                <ItemStyle CssClass="nowrap" />
                                                <HeaderStyle CssClass="txt_center nowrap" />
                                            </asp:BoundField>
                                            <asp:BoundField DataField="payment_format" HeaderText="지출금액">
                                                <ItemStyle CssClass="txt_right nowrap" />
                                                <HeaderStyle CssClass="txt_center nowrap" />
                                            </asp:BoundField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <table class="site-status-empty-table">
                                                <tr>
                                                    <td style="border: 0px none #ffffff;">지출금액이 없습니다.
                                                    </td>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </section>
                        </div>
                        <div class="site-status-result">
                            <asp:Label ID="lblResult" runat="server" CssClass="site-status-result-label"></asp:Label>
                        </div>
                    </div>
                    <div id="divContents3" runat="server" class="site-status-content site-status-summary-board" visible="false">
                    </div>
                </div>
            </div>

        </div>
    </div>

    <asp:HiddenField ID="hdMode" runat="server" />
</asp:Content>

