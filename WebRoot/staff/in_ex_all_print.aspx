<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main_noframe.master" AutoEventWireup="true" CodeFile="in_ex_all_print.aspx.cs" Inherits="staff_in_ex_all_print" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
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
                
                margin-bottom: 10mm;
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
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <div id="divPrint" runat="server" class="[&>div]:mt-[20mm] [&_img]:max-w-full [&_table]:w-full [&_table]:border-collapse [&_table]:text-sm [&_table]:text-ink [&_td]:border [&_td]:border-hairline [&_td]:px-4 [&_td]:py-3 [&_th]:border [&_th]:border-hairline [&_th]:bg-parchment [&_th]:px-4 [&_th]:py-3 [&_th]:text-left [&_th]:font-semibold"></div>

    <asp:HiddenField ID="hdRet" runat="server" />
    <asp:HiddenField ID="hdType" runat="server" />
</asp:Content>

