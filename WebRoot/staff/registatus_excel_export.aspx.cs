using System;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class staff_registatus_excel_export : System.Web.UI.Page
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

        if (!string.IsNullOrEmpty(Request.QueryString["grp"]))
            hdBelong.Value = Request.QueryString["grp"].Trim().Equals(string.Empty) ? "%" : Request.QueryString["grp"].Trim();
        else
            hdBelong.Value = "%";

        if (!string.IsNullOrEmpty(Request.QueryString["reg"]))
            hdRegType.Value = Request.QueryString["reg"].Trim().Equals(string.Empty) ? "%" : Request.QueryString["reg"].Trim();
        else
            hdRegType.Value = "%";
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
            "ubfgj3.dbo.SP_registatus_excel_get_list",
            new SqlParameter("@RETREAT", hdRetreat.Value.Trim()),
            new SqlParameter("@BELONG", hdBelong.Value.Trim()),
            new SqlParameter("@REGI_TYPE", hdRegType.Value.Trim()));

        if (ds.Tables[0].Rows.Count > 0)
        {
            string FileName = "RegistListReport_" + DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".xlsx";
            XlsxExportHelper.WriteDataTableToResponse(Response, ds.Tables[0], FileName, "등록현황");
        }
    }

    //public override void VerifyRenderingInServerForm(Control control)
    //{
    //    //base.VerifyRenderingInServerForm(control);
    //}
    #endregion

    #region 헤더설정
    //protected void gvExcel_RowDataBound(object sender, GridViewRowEventArgs e)
    //{


    //    if (e.Row.RowType == DataControlRowType.Header)
    //    {
            

    //    }
    //}
    #endregion

    
}
