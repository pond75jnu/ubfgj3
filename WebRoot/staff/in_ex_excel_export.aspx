<%@ Page Language="C#" AutoEventWireup="true" CodeFile="in_ex_excel_export.aspx.cs" Inherits="staff_in_ex_excel_export" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title>지출현황 엑셀출력</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="gvExcel" runat="server"></asp:GridView>
        </div>

        <asp:HiddenField ID="hdRetreat" runat="server" />
        <asp:HiddenField ID="hdType" runat="server" />
    </form>
</body>
</html>