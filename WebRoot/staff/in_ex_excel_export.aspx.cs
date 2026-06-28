using System;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class staff_in_ex_excel_export : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;

    private string _url_scheme = HttpContext.Current.Request.Url.Scheme;
    private string _domain = HttpContext.Current.Request.Url.Host;
    private string _path = HttpContext.Current.Request.Url.PathAndQuery;

    #region Page Init
    protected void Page_Init(object sender, EventArgs e)
    {
        //https 리다이렉트
        string _scheme = Request.Url.Scheme.ToString().ToLower();
        if ((_domain.ToLower().Equals("ubfgj3.kr") || _domain.ToLower().Equals("www.ubfgj3.kr")) && _url_scheme.ToLower().Equals("http"))
            Response.Redirect("https://" + _domain + _path, false);
    }
    #endregion

    #region 페이지로드
    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;

        #region 쿼리스트링 체크
        if (!string.IsNullOrEmpty(Request.QueryString["ret"]))
            hdRetreat.Value = Request.QueryString["ret"];
        else
            hdRetreat.Value = string.Empty;

        if (!string.IsNullOrEmpty(Request.QueryString["type"]))
            hdType.Value = Request.QueryString["type"];
        else
            hdType.Value = string.Empty;
        #endregion

        if (!Page.IsPostBack)
        {
            try
            {
                //관리자 및 실무자만 엑셀출력가능
                if (_auth.Equals("admin") || _auth.Equals("manager"))
                    ExportExcel();
            }
            catch (Exception ex)
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('엑셀출력 도중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
            }
        }
    }
    #endregion

    #region 엑셀 Export
    private void ExportExcel()
    {
        string spParam_temp = string.Empty;

        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_income_get_list",
            new SqlParameter("@retreat", hdRetreat.Value),
            new SqlParameter("@cash_type", hdType.Value),
            new SqlParameter("@excel_yn", "Y"));

        if (ds.Tables[0].Rows.Count > 0)
        {
            gvExcel.DataSource = ds;
            gvExcel.DataBind();

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.ClearHeaders();


            if (Request.UserAgent.ToString().ToLower().Contains("windows nt"))
            {
                Response.Charset = "euc-kr";
                Response.ContentEncoding = Encoding.GetEncoding("euc-kr");
            }                
            else
            {
                Response.Charset = "utf-8";
                Response.ContentEncoding = Encoding.GetEncoding("utf-8");
            }
                

            string FileName = string.Empty;
            if (hdType.Value.Equals("1"))
                FileName = "ExpensesReport_" + DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".xls";
            else
                FileName = "IncomesReport_" + DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".xls";

            
            StringWriter swriter = new StringWriter();
            HtmlTextWriter htwriter = new HtmlTextWriter(swriter);

            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", "attachment;filename=" + HttpUtility.UrlEncode(FileName, new UTF8Encoding()));

            gvExcel.GridLines = GridLines.Both;
            gvExcel.HeaderStyle.Font.Bold = true;

            //gvExcel.RenderControl(htwriter);

            gvExcel.RenderBeginTag(htwriter);
            gvExcel.HeaderRow.RenderControl(htwriter);
            foreach (GridViewRow row in gvExcel.Rows)
            {
                row.RenderControl(htwriter);
            }
            gvExcel.FooterRow.RenderControl(htwriter);
            gvExcel.RenderEndTag(htwriter);


            Response.Write(swriter.ToString());
            Response.End();
        }
    }
    #endregion

    


}
