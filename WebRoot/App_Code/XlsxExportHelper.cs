using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.IO.Packaging;
using System.Text;
using System.Web;
using System.Xml;

public static class XlsxExportHelper
{
    private const string SpreadsheetNs = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
    private const string RelationshipsNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
    public static void WriteDataTableToResponse(HttpResponse response, DataTable table, string fileName, string sheetName)
    {
        WriteDataTableToResponse(response, table, fileName, sheetName, false);
    }

    public static void WriteDataTableToResponse(HttpResponse response, DataTable table, string fileName, string sheetName, bool autoFitColumns)
    {
        if (!fileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase))
            fileName += ".xlsx";

        using (MemoryStream workbookStream = new MemoryStream())
        {
            WriteWorkbook(workbookStream, table, sheetName, autoFitColumns);

            response.Clear();
            response.Buffer = true;
            response.ClearContent();
            response.ClearHeaders();
            response.Cache.SetCacheability(HttpCacheability.NoCache);
            response.Charset = string.Empty;
            response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            response.AddHeader("content-disposition", "attachment;filename=" + HttpUtility.UrlEncode(fileName, Encoding.UTF8));
            response.BinaryWrite(workbookStream.ToArray());
            response.End();
        }
    }

    private static void WriteWorkbook(Stream output, DataTable table, string sheetName, bool autoFitColumns)
    {
        using (Package package = Package.Open(output, FileMode.Create, FileAccess.ReadWrite))
        {
            Uri workbookUri = PackUriHelper.CreatePartUri(new Uri("/xl/workbook.xml", UriKind.Relative));
            Uri worksheetUri = PackUriHelper.CreatePartUri(new Uri("/xl/worksheets/sheet1.xml", UriKind.Relative));
            Uri stylesUri = PackUriHelper.CreatePartUri(new Uri("/xl/styles.xml", UriKind.Relative));

            PackagePart workbookPart = package.CreatePart(
                workbookUri,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
                CompressionOption.Maximum);
            PackagePart worksheetPart = package.CreatePart(
                worksheetUri,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
                CompressionOption.Maximum);
            PackagePart stylesPart = package.CreatePart(
                stylesUri,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml",
                CompressionOption.Maximum);

            package.CreateRelationship(
                workbookUri,
                TargetMode.Internal,
                RelationshipsNs + "/officeDocument",
                "rId1");
            workbookPart.CreateRelationship(
                new Uri("worksheets/sheet1.xml", UriKind.Relative),
                TargetMode.Internal,
                RelationshipsNs + "/worksheet",
                "rId1");
            workbookPart.CreateRelationship(
                new Uri("styles.xml", UriKind.Relative),
                TargetMode.Internal,
                RelationshipsNs + "/styles",
                "rId2");

            WriteWorkbookXml(workbookPart, sheetName);
            WriteWorksheetXml(worksheetPart, table, autoFitColumns);
            WriteStylesXml(stylesPart);
        }
    }

    private static void WriteWorkbookXml(PackagePart workbookPart, string sheetName)
    {
        using (XmlWriter writer = CreateXmlWriter(workbookPart.GetStream()))
        {
            writer.WriteStartDocument(true);
            writer.WriteStartElement("workbook", SpreadsheetNs);
            writer.WriteAttributeString("xmlns", "r", null, RelationshipsNs);
            writer.WriteStartElement("sheets", SpreadsheetNs);
            writer.WriteStartElement("sheet", SpreadsheetNs);
            writer.WriteAttributeString("name", CleanSheetName(sheetName));
            writer.WriteAttributeString("sheetId", "1");
            writer.WriteAttributeString("r", "id", RelationshipsNs, "rId1");
            writer.WriteEndElement();
            writer.WriteEndElement();
            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    private static void WriteWorksheetXml(PackagePart worksheetPart, DataTable table, bool autoFitColumns)
    {
        int rowCount = Math.Max(1, table.Rows.Count + 1);
        int columnCount = Math.Max(1, table.Columns.Count);

        using (XmlWriter writer = CreateXmlWriter(worksheetPart.GetStream()))
        {
            writer.WriteStartDocument(true);
            writer.WriteStartElement("worksheet", SpreadsheetNs);
            writer.WriteStartElement("dimension", SpreadsheetNs);
            writer.WriteAttributeString("ref", "A1:" + GetCellReference(columnCount, rowCount));
            writer.WriteEndElement();
            if (autoFitColumns)
                WriteColumnsXml(writer, table);
            writer.WriteStartElement("sheetData", SpreadsheetNs);

            writer.WriteStartElement("row", SpreadsheetNs);
            writer.WriteAttributeString("r", "1");
            for (int columnIndex = 0; columnIndex < table.Columns.Count; columnIndex++)
            {
                WriteTextCell(writer, columnIndex + 1, 1, table.Columns[columnIndex].ColumnName, "1");
            }
            writer.WriteEndElement();

            for (int rowIndex = 0; rowIndex < table.Rows.Count; rowIndex++)
            {
                int excelRowIndex = rowIndex + 2;
                writer.WriteStartElement("row", SpreadsheetNs);
                writer.WriteAttributeString("r", excelRowIndex.ToString(CultureInfo.InvariantCulture));

                for (int columnIndex = 0; columnIndex < table.Columns.Count; columnIndex++)
                {
                    object value = table.Rows[rowIndex][columnIndex];
                    DataColumn column = table.Columns[columnIndex];

                    if (value == DBNull.Value || value == null)
                        WriteTextCell(writer, columnIndex + 1, excelRowIndex, string.Empty, null);
                    else if (IsNumericType(column.DataType))
                        WriteNumberCell(writer, columnIndex + 1, excelRowIndex, value);
                    else
                        WriteTextCell(writer, columnIndex + 1, excelRowIndex, Convert.ToString(value, CultureInfo.CurrentCulture), null);
                }

                writer.WriteEndElement();
            }

            writer.WriteEndElement();
            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    private static void WriteColumnsXml(XmlWriter writer, DataTable table)
    {
        writer.WriteStartElement("cols", SpreadsheetNs);
        for (int columnIndex = 0; columnIndex < table.Columns.Count; columnIndex++)
        {
            double width = GetAutoFitWidth(table, columnIndex);
            writer.WriteStartElement("col", SpreadsheetNs);
            writer.WriteAttributeString("min", (columnIndex + 1).ToString(CultureInfo.InvariantCulture));
            writer.WriteAttributeString("max", (columnIndex + 1).ToString(CultureInfo.InvariantCulture));
            writer.WriteAttributeString("width", width.ToString("0.##", CultureInfo.InvariantCulture));
            writer.WriteAttributeString("customWidth", "1");
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static double GetAutoFitWidth(DataTable table, int columnIndex)
    {
        int maxLength = GetDisplayLength(table.Columns[columnIndex].ColumnName);
        foreach (DataRow row in table.Rows)
        {
            object value = row[columnIndex];
            if (value == null || value == DBNull.Value)
                continue;

            int length = GetDisplayLength(Convert.ToString(value, CultureInfo.CurrentCulture));
            if (length > maxLength)
                maxLength = length;
        }

        return Math.Min(255D, Math.Max(8D, maxLength + 2D));
    }

    private static int GetDisplayLength(string value)
    {
        if (String.IsNullOrEmpty(value))
            return 0;

        int currentLineLength = 0;
        int maxLineLength = 0;
        foreach (char character in value)
        {
            if (character == '\r')
                continue;
            if (character == '\n')
            {
                maxLineLength = Math.Max(maxLineLength, currentLineLength);
                currentLineLength = 0;
                continue;
            }

            currentLineLength += character <= 0x7f ? 1 : 2;
        }
        return Math.Max(maxLineLength, currentLineLength);
    }

    private static void WriteStylesXml(PackagePart stylesPart)
    {
        using (XmlWriter writer = CreateXmlWriter(stylesPart.GetStream()))
        {
            writer.WriteStartDocument(true);
            writer.WriteStartElement("styleSheet", SpreadsheetNs);

            writer.WriteStartElement("fonts", SpreadsheetNs);
            writer.WriteAttributeString("count", "2");
            WriteFont(writer, false);
            WriteFont(writer, true);
            writer.WriteEndElement();

            writer.WriteStartElement("fills", SpreadsheetNs);
            writer.WriteAttributeString("count", "2");
            writer.WriteStartElement("fill", SpreadsheetNs);
            writer.WriteStartElement("patternFill", SpreadsheetNs);
            writer.WriteAttributeString("patternType", "none");
            writer.WriteEndElement();
            writer.WriteEndElement();
            writer.WriteStartElement("fill", SpreadsheetNs);
            writer.WriteStartElement("patternFill", SpreadsheetNs);
            writer.WriteAttributeString("patternType", "gray125");
            writer.WriteEndElement();
            writer.WriteEndElement();
            writer.WriteEndElement();

            writer.WriteStartElement("borders", SpreadsheetNs);
            writer.WriteAttributeString("count", "1");
            writer.WriteStartElement("border", SpreadsheetNs);
            writer.WriteElementString("left", SpreadsheetNs, string.Empty);
            writer.WriteElementString("right", SpreadsheetNs, string.Empty);
            writer.WriteElementString("top", SpreadsheetNs, string.Empty);
            writer.WriteElementString("bottom", SpreadsheetNs, string.Empty);
            writer.WriteElementString("diagonal", SpreadsheetNs, string.Empty);
            writer.WriteEndElement();
            writer.WriteEndElement();

            writer.WriteStartElement("cellStyleXfs", SpreadsheetNs);
            writer.WriteAttributeString("count", "1");
            WriteXf(writer, 0);
            writer.WriteEndElement();

            writer.WriteStartElement("cellXfs", SpreadsheetNs);
            writer.WriteAttributeString("count", "2");
            WriteXf(writer, 0);
            WriteXf(writer, 1);
            writer.WriteEndElement();

            writer.WriteStartElement("cellStyles", SpreadsheetNs);
            writer.WriteAttributeString("count", "1");
            writer.WriteStartElement("cellStyle", SpreadsheetNs);
            writer.WriteAttributeString("name", "Normal");
            writer.WriteAttributeString("xfId", "0");
            writer.WriteAttributeString("builtinId", "0");
            writer.WriteEndElement();
            writer.WriteEndElement();

            writer.WriteStartElement("dxfs", SpreadsheetNs);
            writer.WriteAttributeString("count", "0");
            writer.WriteEndElement();

            writer.WriteStartElement("tableStyles", SpreadsheetNs);
            writer.WriteAttributeString("count", "0");
            writer.WriteAttributeString("defaultTableStyle", "TableStyleMedium2");
            writer.WriteAttributeString("defaultPivotStyle", "PivotStyleLight16");
            writer.WriteEndElement();

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    private static XmlWriter CreateXmlWriter(Stream stream)
    {
        XmlWriterSettings settings = new XmlWriterSettings();
        settings.Encoding = new UTF8Encoding(false);
        settings.Indent = false;
        return XmlWriter.Create(stream, settings);
    }

    private static void WriteFont(XmlWriter writer, bool bold)
    {
        writer.WriteStartElement("font", SpreadsheetNs);
        if (bold)
            writer.WriteElementString("b", SpreadsheetNs, string.Empty);
        writer.WriteStartElement("sz", SpreadsheetNs);
        writer.WriteAttributeString("val", "11");
        writer.WriteEndElement();
        writer.WriteStartElement("color", SpreadsheetNs);
        writer.WriteAttributeString("theme", "1");
        writer.WriteEndElement();
        writer.WriteStartElement("name", SpreadsheetNs);
        writer.WriteAttributeString("val", "Calibri");
        writer.WriteEndElement();
        writer.WriteStartElement("family", SpreadsheetNs);
        writer.WriteAttributeString("val", "2");
        writer.WriteEndElement();
        writer.WriteEndElement();
    }

    private static void WriteXf(XmlWriter writer, int fontId)
    {
        writer.WriteStartElement("xf", SpreadsheetNs);
        writer.WriteAttributeString("numFmtId", "0");
        writer.WriteAttributeString("fontId", fontId.ToString(CultureInfo.InvariantCulture));
        writer.WriteAttributeString("fillId", "0");
        writer.WriteAttributeString("borderId", "0");
        writer.WriteAttributeString("xfId", "0");
        if (fontId != 0)
            writer.WriteAttributeString("applyFont", "1");
        writer.WriteEndElement();
    }

    private static void WriteTextCell(XmlWriter writer, int columnIndex, int rowIndex, string value, string styleIndex)
    {
        writer.WriteStartElement("c", SpreadsheetNs);
        writer.WriteAttributeString("r", GetCellReference(columnIndex, rowIndex));
        if (!string.IsNullOrEmpty(styleIndex))
            writer.WriteAttributeString("s", styleIndex);
        writer.WriteAttributeString("t", "inlineStr");
        writer.WriteStartElement("is", SpreadsheetNs);
        writer.WriteStartElement("t", SpreadsheetNs);
        if (RequiresPreserveSpace(value))
            writer.WriteAttributeString("xml", "space", "http://www.w3.org/XML/1998/namespace", "preserve");
        writer.WriteString(value ?? string.Empty);
        writer.WriteEndElement();
        writer.WriteEndElement();
        writer.WriteEndElement();
    }

    private static void WriteNumberCell(XmlWriter writer, int columnIndex, int rowIndex, object value)
    {
        writer.WriteStartElement("c", SpreadsheetNs);
        writer.WriteAttributeString("r", GetCellReference(columnIndex, rowIndex));
        writer.WriteStartElement("v", SpreadsheetNs);
        writer.WriteString(Convert.ToString(value, CultureInfo.InvariantCulture));
        writer.WriteEndElement();
        writer.WriteEndElement();
    }

    private static bool IsNumericType(Type type)
    {
        TypeCode typeCode = Type.GetTypeCode(type);
        return typeCode == TypeCode.Byte
            || typeCode == TypeCode.SByte
            || typeCode == TypeCode.Int16
            || typeCode == TypeCode.UInt16
            || typeCode == TypeCode.Int32
            || typeCode == TypeCode.UInt32
            || typeCode == TypeCode.Int64
            || typeCode == TypeCode.UInt64
            || typeCode == TypeCode.Single
            || typeCode == TypeCode.Double
            || typeCode == TypeCode.Decimal;
    }

    private static string GetCellReference(int columnIndex, int rowIndex)
    {
        return GetColumnName(columnIndex) + rowIndex.ToString(CultureInfo.InvariantCulture);
    }

    private static string GetColumnName(int columnIndex)
    {
        StringBuilder columnName = new StringBuilder();

        while (columnIndex > 0)
        {
            int modulo = (columnIndex - 1) % 26;
            columnName.Insert(0, Convert.ToChar('A' + modulo));
            columnIndex = (columnIndex - modulo) / 26;
        }

        return columnName.ToString();
    }

    private static string CleanSheetName(string sheetName)
    {
        if (string.IsNullOrEmpty(sheetName))
            return "Sheet1";

        char[] invalidChars = new char[] { ':', '\\', '/', '?', '*', '[', ']' };
        string cleanName = sheetName;

        for (int i = 0; i < invalidChars.Length; i++)
        {
            cleanName = cleanName.Replace(invalidChars[i], ' ');
        }

        cleanName = cleanName.Trim();
        if (cleanName.Length == 0)
            cleanName = "Sheet1";
        if (cleanName.Length > 31)
            cleanName = cleanName.Substring(0, 31);

        return cleanName;
    }

    private static bool RequiresPreserveSpace(string value)
    {
        return !string.IsNullOrEmpty(value) && (value[0] == ' ' || value[value.Length - 1] == ' ');
    }
}
