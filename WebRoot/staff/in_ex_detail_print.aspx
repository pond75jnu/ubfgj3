<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main_noframe.master" AutoEventWireup="true" CodeFile="in_ex_detail_print.aspx.cs" Inherits="staff_in_ex_detail_print" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        @media screen {
            body {
                margin-top: 10mm;
                margin-bottom: 10mm;
                margin-left: 10mm;
                margin-right: 10mm;
            }
        }

        @media print {
            body {
                margin-top: 20mm;
                margin-bottom: 20mm;
                margin-left: 20mm;
                margin-right: 20mm;
            }
        }

        .print_img {
            max-width:380px;
            max-height:530px;
        }
    </style>
    <script>
        window.onload = function () {
            window.print();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <table class="w-full border-collapse text-sm text-ink [&_td]:border [&_td]:border-hairline [&_td]:px-4 [&_td]:py-3 [&_th]:border [&_th]:border-hairline [&_th]:bg-parchment [&_th]:px-4 [&_th]:py-3 [&_th]:text-left [&_th]:font-semibold">
        <tr>
            <th class="nowrap" style="width: 120px;">
                <% if (hdType.Value.Equals("1"))
                    { %>                
                수입항목
                <% }
                    else if (hdType.Value.Equals("2"))
                    { %>
                지출항목
                <% }
                else
                {%>
                항목
                <% } %>
            </th>
            <td>
                <asp:Label ID="lblItem" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <th class="nowrap">
                <% if (hdType.Value.Equals("1"))
                    { %>                
                수입내용
                <% }
                    else if (hdType.Value.Equals("2"))
                    { %>
                지출내용
                <% }
                else
                {%>
                내용
                <% } %>
            </th>
            <td>
                <asp:Label ID="lblTitle" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <th class="nowrap">
                <% if (hdType.Value.Equals("1"))
                    { %>                
                수입금액
                <% }
                    else if (hdType.Value.Equals("2"))
                    { %>
                지출비용
                <% }
                else
                {%>
                비용
                <% } %>
            </th>
            <td>
                <asp:Label ID="lblPay" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <th class="nowrap">
                <% if (hdType.Value.Equals("1"))
                    { %>                
                수입일자
                <% }
                    else if (hdType.Value.Equals("2"))
                    { %>
                지출일자
                <% }
                else
                {%>
                일자
                <% } %>
            </th>
            <td>
                <asp:Label ID="lblDT" runat="server"></asp:Label>
            </td>
        </tr>
        <tr id="trImage" runat="server">
            <th class="nowrap">
                <% if (hdType.Value.Equals("1"))
                    { %>                
                증빙자료
                <% }
                    else if (hdType.Value.Equals("2"))
                    { %>
                영수증
                <% }
                else
                {%>
                증빙
                <% } %>
            </th>
            <td>
                <asp:Image ID="AttatchImage" runat="server" CssClass="max-w-full print_img" AlternateText="image" />
            </td>
        </tr>
        <tr>
            <th class="nowrap">비고</th>
            <td>
                <asp:Label ID="lblEtc" runat="server"></asp:Label>
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="hdSeq" runat="server" />
    <asp:HiddenField ID="hdType" runat="server" />
</asp:Content>

