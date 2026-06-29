using System;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Hosting;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// CodeHelper의 요약 설명입니다.
/// </summary>
public class CodeHelper
{
    public CodeHelper()
    {
        //
        // TODO: 여기에 생성자 논리를 추가합니다.
        //
    }

    public static string GetCurrentCanonicalPath()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Request == null || ctx.Request.Url == null)
            return "/";

        return ToCanonicalPath(ctx.Request.Url.AbsolutePath);
    }

    public static string GetCurrentMenuPath()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Request == null || ctx.Request.Url == null)
            return "/";

        return ToMenuPath(ctx.Request.Url.AbsolutePath);
    }

    public static string ToCanonicalPath(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
            return "/";

        string normalized = path.Trim().Replace('\\', '/');
        int queryIndex = normalized.IndexOf('?');
        if (queryIndex >= 0)
            normalized = normalized.Substring(0, queryIndex);

        int hashIndex = normalized.IndexOf('#');
        if (hashIndex >= 0)
            normalized = normalized.Substring(0, hashIndex);

        if (!normalized.StartsWith("/"))
            normalized = "/" + normalized;

        normalized = normalized.ToLowerInvariant();

        if (normalized.Equals("/default.aspx") || normalized.Equals("/default"))
            return "/";

        if (normalized.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
            normalized = normalized.Substring(0, normalized.Length - ".aspx".Length);

        return normalized.Equals(string.Empty) ? "/" : normalized;
    }

    public static string ToMenuPath(string path)
    {
        string canonicalPath = ToCanonicalPath(path);
        if (canonicalPath.Equals("/"))
            return "/";

        string aspxPath = canonicalPath + ".aspx";
        if (VirtualAspxExists(aspxPath))
            return aspxPath;

        return canonicalPath;
    }

    public static string ToCanonicalUrl(string url)
    {
        if (string.IsNullOrWhiteSpace(url))
            return url;

        Uri absoluteUri;
        if (Uri.TryCreate(url, UriKind.Absolute, out absoluteUri))
        {
            return absoluteUri.GetLeftPart(UriPartial.Authority)
                + ToCanonicalPath(absoluteUri.AbsolutePath)
                + absoluteUri.Query
                + absoluteUri.Fragment;
        }

        string fragment = string.Empty;
        string pathAndQuery = url.Trim();
        int hashIndex = pathAndQuery.IndexOf('#');
        if (hashIndex >= 0)
        {
            fragment = pathAndQuery.Substring(hashIndex);
            pathAndQuery = pathAndQuery.Substring(0, hashIndex);
        }

        string query = string.Empty;
        string path = pathAndQuery;
        int queryIndex = pathAndQuery.IndexOf('?');
        if (queryIndex >= 0)
        {
            query = pathAndQuery.Substring(queryIndex);
            path = pathAndQuery.Substring(0, queryIndex);
        }

        bool isRelativePath = !path.StartsWith("/");
        string canonicalPath = ToCanonicalPath(isRelativePath ? "/" + path : path);
        if (isRelativePath)
            canonicalPath = canonicalPath.TrimStart('/');

        return canonicalPath + query + fragment;
    }

    private static bool VirtualAspxExists(string virtualPath)
    {
        try
        {
            if (HostingEnvironment.VirtualPathProvider != null
                && HostingEnvironment.VirtualPathProvider.FileExists(virtualPath))
                return true;
        }
        catch
        {
        }

        try
        {
            HttpContext ctx = HttpContext.Current;
            if (ctx == null)
                return false;

            string physicalPath = ctx.Server.MapPath(virtualPath);
            return File.Exists(physicalPath);
        }
        catch
        {
            return false;
        }
    }

    public enum MessageType
    {
        Information,
        Confirm,
        Error
    }

    #region Redirect()

    public static void Redirect(string message, string url)
    {
        HttpContext ctx = HttpContext.Current;

        ctx.Response.Clear();

        url = ToCanonicalUrl(url);
        string SCRIPT_MESSAGE_REDIRECT = @"<script language='javascript'>alert('{0}'); window.location='{1}';</script>";
        ctx.Response.Write(String.Format(SCRIPT_MESSAGE_REDIRECT, message, url));

        ctx.Response.Flush();
        ctx.Response.End();
    }
    public static void Redirect(string url)
    {
        HttpContext ctx = HttpContext.Current;

        ctx.Response.Clear();

        url = ToCanonicalUrl(url);
        string SCRIPT_REDIRECT = @"<script language='javascript'>window.location='{0}';</script>";
        ctx.Response.Write(String.Format(SCRIPT_REDIRECT, url));

        ctx.Response.Flush();
        ctx.Response.End();
    }
    #endregion

    #region ShowMessageBox()

    /// <summary>
    /// 메시지 박스를 출력한다.
    /// </summary>
    /// <param name="page">대상 페이지</param>
    /// <param name="key">스크립트Key</param>
    /// <param name="message">출력메시지</param>
    public static void ShowMessageBox(Page page, string key, string message)
    {
        ShowMessageBox(page, key, message, MessageType.Information);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="page"></param>
    /// <param name="key"></param>
    /// <param name="message"></param>
    /// <param name="type"></param>
    public static void ShowMessageBox(Page page, string key, string message, MessageType type)
    {
        if (!page.ClientScript.IsStartupScriptRegistered(key))
        {
            string SCRIPT_MESSAGEBOX = String.Format("alert('{0}')", message);

            page.ClientScript.RegisterStartupScript(page.GetType(), key, SCRIPT_MESSAGEBOX, true);
        }
    }

    #endregion

    /// <summary>
    /// 체크폼 설정
    /// </summary>
    /// <param name="formID"></param>
    /// <returns></returns>
    public static bool ValidateCheck(string formID)
    {
        return !String.IsNullOrEmpty(formID);
    }

    public static bool TryParseWholeWon(string value, out decimal amount)
    {
        amount = 0;

        string normalized = (value ?? string.Empty).Trim().Replace(",", string.Empty);
        if (normalized.Equals(string.Empty))
            normalized = "0";

        if (!Regex.IsMatch(normalized, @"^\d+$"))
            return false;

        return decimal.TryParse(normalized, NumberStyles.None, CultureInfo.InvariantCulture, out amount);
    }

    public static decimal ParseWholeWon(string value, string fieldName)
    {
        decimal amount;
        if (!TryParseWholeWon(value, out amount))
            throw new ArgumentException(fieldName + "은(는) 0 이상의 숫자만 입력할 수 있습니다.");

        return amount;
    }

    public static decimal ParsePositiveWholeWon(string value, string fieldName)
    {
        decimal amount = ParseWholeWon(value, fieldName);
        if (amount <= 0)
            throw new ArgumentException(fieldName + "은(는) 0보다 큰 숫자를 입력해야 합니다.");

        return amount;
    }

    public static int ParseWholeWonInt(string value, string fieldName)
    {
        decimal amount = ParseWholeWon(value, fieldName);
        if (amount > Int32.MaxValue)
            throw new ArgumentException(fieldName + "은(는) 입력 가능한 금액 범위를 초과했습니다.");

        return Convert.ToInt32(amount);
    }

    private string GetFileNameFromAccountName(string accountName)
    {
        string result = accountName;
        //string charsToReplace = @"\/:*?""<>|";
        //System.Array.ForEach(charsToReplace.ToCharArray(), charToReplace => result = result.Replace(charToReplace, '_'));
        //foreach (char charToReplace in charsToReplace.ToCharArray())
        //    result = result.Replace(charToReplace, '_');
        //foreach (char charToReplace in charsToReplace.ToCharArray())
        //{ result = result.Replace(charToReplace, '_'); }
        result = result.Replace('\\', '_');
        result = result.Replace('/', '_');
        result = result.Replace(':', '_');
        result = result.Replace('*', '_');
        result = result.Replace('{', '_');
        result = result.Replace('}', '_');
        result = result.Replace('|', '_');
        result = result.Replace('?', '_');
        result = result.Replace('<', '_');
        result = result.Replace('>', '_');
        result = result.Replace('#', '_');
        result = result.Replace('%', '_');
        result = result.Replace('&', '_');

        return result;
    }


    #region IP정보 반환
    /// <summary>
    ///  Client IP
    /// </summary>
    public static string GetUserIP
    {
        get
        {

            string IP4Address = String.Empty;

            foreach (IPAddress IPA in Dns.GetHostAddresses(HttpContext.Current.Request.UserHostAddress))
            {
                if (IPA.AddressFamily.ToString() == "InterNetwork")
                {
                    IP4Address = IPA.ToString();
                    break;
                }
            }

            if (IP4Address != String.Empty)
            {
                return IP4Address;
            }

            foreach (IPAddress IPA in Dns.GetHostAddresses(Dns.GetHostName()))
            {
                if (IPA.AddressFamily.ToString() == "InterNetwork")
                {
                    IP4Address = IPA.ToString();
                    break;
                }
            }

            return IP4Address;
        }

    }
    #endregion

    public static string RetreatCode
    {
        get
        {

            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_current_code_sel");

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["seq"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }

    }

    public static string GetGroupName(string _group_code)
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_group_name_sel",
            new SqlParameter("@Seq", _group_code));

        if (ds.Tables[0].Rows.Count > 0)
        {
            return ds.Tables[0].Rows[0]["belong_nm"].ToString();
        }
        else
        {
            return string.Empty;
        }
    }

    public static string GetPagetitle(string _menu_path)
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_menu_page_title_sel",
            new SqlParameter("@MenuPath", ToMenuPath(_menu_path).ToLower()));

        if (ds.Tables[0].Rows.Count > 0)
        {
            return ds.Tables[0].Rows[0]["menu_nm"].ToString();
        }
        else
        {
            return string.Empty;
        }
    }

    public static string GetCashCode(string _payment_seq)
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_payment_master_by_seq_sel",
            new SqlParameter("@Seq", _payment_seq));

        if (ds.Tables[0].Rows.Count > 0)
        {
            return ds.Tables[0].Rows[0]["cash_item_seq"].ToString();
        }
        else
        {
            return string.Empty;
        }
    }

    public static string GetFilePath(string _seq)
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_payment_master_by_seq_sel",
            new SqlParameter("@Seq", _seq));

        if (ds.Tables[0].Rows.Count > 0)
        {
            return ds.Tables[0].Rows[0]["file_path"].ToString();
        }
        else
        {
            return string.Empty;
        }
    }

    public static string GetFileUrl(string _seq)
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_payment_master_by_seq_sel",
            new SqlParameter("@Seq", _seq));

        if (ds.Tables[0].Rows.Count > 0)
        {
            return ds.Tables[0].Rows[0]["file_url"].ToString();
        }
        else
        {
            return string.Empty;
        }
    }

    public static string spParm(string[] sp_params)
    {
        string spReportParam_temp = string.Empty;
        string spReport_PARAM = string.Empty;
        for (int i = 0; i < sp_params.Length; i++)
        {
            spReportParam_temp = spReportParam_temp + "N'" + sp_params[i].ToString() + @"',";
        }
        spReport_PARAM = spReportParam_temp.Substring(0, spReportParam_temp.Length - 1);

        return spReport_PARAM;
    }

    #region 메일발송
    public static bool SendMail(string sendname, string title, string receivemail, string mailmessage, bool ssl)
    {

        try
        {
            SmtpSetting smtpConfig = AppConfiguration.Smtp;

            //수신자            
            string receiveID = receivemail;
            string msgTitle = title;
            string msgContent = mailmessage;

            //메일 컨텐츠 설정 (발송자, 수신자, 메일제목, 메일내용 등..)
            MailMessage message = new MailMessage();

            if (sendname.Trim().Equals(string.Empty))
                message.From = new MailAddress(smtpConfig.From, "ubfgj3", Encoding.UTF8);
            else
                message.From = new MailAddress(smtpConfig.From, sendname, Encoding.UTF8);


            message.To.Add(new MailAddress(receiveID));

            //string someArrows = new string(new char[] { '\u2190', '\u2191', '\u2192', '\u2193' });

            message.Subject = msgTitle;// + someArrows;
            message.Body = msgContent;
            //message.Body += Environment.NewLine + someArrows;
            message.SubjectEncoding = Encoding.UTF8;  //메일 제목의 Encoding을 UTF8로 설정
            message.BodyEncoding = Encoding.UTF8;     //메일 내용의 Encoding을 UTF8로 설정
            message.IsBodyHtml = true;                //메일 본문을 HTML형식을 지원하도록 설정


            //SMTP 설정
            SmtpClient smtpClient = new SmtpClient(smtpConfig.Host, smtpConfig.Port);
            smtpClient.UseDefaultCredentials = smtpConfig.DefaultCredentials;// 시스템에 설정된 인증 정보를 사용하지 않는다.
            smtpClient.EnableSsl = smtpConfig.EnableSsl;  // SSL을 사용한다.

            //Gmail에 인증을 위한 설정
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;

            //SMTP서버로부터 인증을 받기위한 Credentials 생성
            smtpClient.Credentials = new NetworkCredential(smtpConfig.UserName, smtpConfig.Password);

            //Send 메서드를 이용하여 메일을 발송한다.
            smtpClient.Send(message);

            return true;
        }
        catch (Exception)
        {
            return false;
        }

    }
    #endregion
}
