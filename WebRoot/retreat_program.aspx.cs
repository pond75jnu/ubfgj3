using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;

public partial class retreat_program : System.Web.UI.Page
{
    private bool responseHandled;

    protected void Page_Load(object sender, EventArgs e)
    {
        WriteActiveProgramFile();
    }

    private void WriteActiveProgramFile()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_file_sel");
            if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                WriteStatus(404, "안내 파일을 찾을 수 없습니다.");
                return;
            }

            DataRow row = ds.Tables[0].Rows[0];
            string fileName = Convert.ToString(row["file_nm"]);
            object fileData = row["file_data"];

            if (string.IsNullOrWhiteSpace(fileName) || fileData == DBNull.Value)
            {
                WriteStatus(404, "안내 파일을 찾을 수 없습니다.");
                return;
            }

            byte[] byteFile = (byte[])fileData;
            string contentType = GetContentType(fileName, GetString(row, "file_type"));
            bool forceDownload = string.Equals(Request.QueryString["download"], "1", StringComparison.Ordinal);

            Response.Clear();
            Response.BufferOutput = true;
            Response.ContentType = contentType;
            Response.AppendHeader("Content-Disposition", BuildContentDisposition(fileName, forceDownload));
            Response.AppendHeader("Content-Length", byteFile.Length.ToString());
            Response.AppendHeader("X-Content-Type-Options", "nosniff");
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.BinaryWrite(byteFile);

            CompleteResponse();
        }
        catch (Exception ex)
        {
            WriteStatus(500, "안내 파일을 여는 중 오류가 발생했습니다: " + Server.HtmlEncode(ex.Message));
        }
    }

    private static string GetString(DataRow row, string columnName)
    {
        if (!row.Table.Columns.Contains(columnName) || row[columnName] == DBNull.Value)
            return string.Empty;

        return Convert.ToString(row[columnName]);
    }

    private static string GetContentType(string fileName, string storedContentType)
    {
        if (!string.IsNullOrWhiteSpace(storedContentType) && storedContentType.Contains("/"))
            return storedContentType;

        switch (Path.GetExtension(fileName).ToLowerInvariant())
        {
            case ".pdf":
                return "application/pdf";
            case ".jpg":
            case ".jpeg":
                return "image/jpeg";
            case ".png":
                return "image/png";
            case ".gif":
                return "image/gif";
            case ".webp":
                return "image/webp";
            default:
                return "application/octet-stream";
        }
    }

    private static string BuildContentDisposition(string fileName, bool forceDownload)
    {
        string extension = Path.GetExtension(fileName);
        string fallbackFileName = "retreat-program" + (string.IsNullOrWhiteSpace(extension) ? ".pdf" : extension);
        string disposition = forceDownload ? "attachment" : "inline";

        return disposition + "; filename=\"" + SanitizeHeaderValue(fallbackFileName) + "\"; filename*=UTF-8''" + Uri.EscapeDataString(fileName);
    }

    private static string SanitizeHeaderValue(string value)
    {
        return value
            .Replace("\r", string.Empty)
            .Replace("\n", string.Empty)
            .Replace("\"", string.Empty);
    }

    private void WriteStatus(int statusCode, string message)
    {
        Response.Clear();
        Response.StatusCode = statusCode;
        Response.ContentType = "text/plain; charset=utf-8";
        Response.Write(message);
        CompleteResponse();
    }

    private void CompleteResponse()
    {
        responseHandled = true;
        Context.ApplicationInstance.CompleteRequest();
    }

    protected override void Render(HtmlTextWriter writer)
    {
        if (responseHandled)
            return;

        base.Render(writer);
    }
}
