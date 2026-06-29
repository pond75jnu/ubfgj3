using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

public partial class staff_in_ex_detail_print : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;

    private string _url_scheme = HttpContext.Current.Request.Url.Scheme;
    private string _domain = HttpContext.Current.Request.Url.Host;
    private string _path = CodeHelper.ToCanonicalUrl(HttpContext.Current.Request.Url.PathAndQuery);

    #region Page Init
    protected void Page_Init(object sender, EventArgs e)
    {
        //https 리다이렉트
        string _scheme = Request.Url.Scheme.ToString().ToLower();
        if ((_domain.ToLower().Equals("ubfgj3.kr") || _domain.ToLower().Equals("www.ubfgj3.kr")) && _url_scheme.ToLower().Equals("http"))
            Response.Redirect("https://" + _domain + _path, false);
    }
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;

        #region 쿼리스트링 체크
        if (!string.IsNullOrEmpty(Request.QueryString["seq"]))
            hdSeq.Value = Request.QueryString["seq"];
        else
            hdSeq.Value = string.Empty;

        if (!string.IsNullOrEmpty(Request.QueryString["type"]))
            hdType.Value = Request.QueryString["type"];
        else
            hdType.Value = string.Empty;
        #endregion

        if (!Page.IsPostBack)
        {
            try
            {
                switch (hdType.Value)
                {
                    case "1":
                        Page.Title = "수입내용 인쇄";
                        break;
                    case "2":
                        Page.Title = "지출내용 인쇄";
                        break;
                    default:
                        Page.Title = "내용 인쇄";
                        break;
                }

                //관리자 및 실무자만 엑셀출력가능
                if (_auth.Equals("admin") || _auth.Equals("manager"))
                    GetDetail();
            }
            catch (Exception ex)
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부내용 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
            }
        }
    }

    protected void GetDetail()
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_payment_print_detail_get",
            new SqlParameter("@SEQ", hdSeq.Value.ToString().Trim()),
            new SqlParameter("@CASH_TYPE", hdType.Value.ToString().Trim()));

        if (ds.Tables[0].Rows.Count > 0)
        {
            lblItem.Text = ds.Tables[0].Rows[0]["item_nm"].ToString().Trim();
            lblTitle.Text = ds.Tables[0].Rows[0]["payment_item"].ToString().Trim();
            lblPay.Text = ds.Tables[0].Rows[0]["payment_format"].ToString().Trim();
            lblDT.Text = ds.Tables[0].Rows[0]["payment_dt"].ToString().Trim();
            lblEtc.Text = ds.Tables[0].Rows[0]["payment_item_desc"].ToString().Trim();

            if (!ds.Tables[0].Rows[0]["file_nm"].ToString().Trim().Equals(string.Empty))
            {
                trImage.Visible = true;
                AttatchImage.ImageUrl = ds.Tables[0].Rows[0]["file_url"].ToString().Trim();

            }
            else
                trImage.Visible = false;
        }
    }

}
