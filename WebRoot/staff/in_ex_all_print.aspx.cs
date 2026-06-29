using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;
using System.Text;
public partial class staff_in_ex_all_print : System.Web.UI.Page
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
        if (!string.IsNullOrEmpty(Request.QueryString["ret"]))
            hdRet.Value = Request.QueryString["ret"];
        else
            hdRet.Value = string.Empty;

        if (!string.IsNullOrEmpty(Request.QueryString["type"]))
            hdType.Value = Request.QueryString["type"];
        else
            hdType.Value = string.Empty;
        #endregion

        if (!Page.IsPostBack)
        {
            switch (hdType.Value)
            {
                case "1":
                    Page.Title = "수입현황(전체) 인쇄";
                    break;
                case "2":
                    Page.Title = "지출현황(전체) 인쇄";
                    break;
                default:
                    Page.Title = "전체현황 인쇄";
                    break;
            }

            try
            {
                //관리자 및 실무자만 엑셀출력가능
                if (_auth.Equals("admin") || _auth.Equals("manager"))
                    GetList();
            }
            catch (Exception ex)
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
            }
        }
    }

    protected void GetList()
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_income_get_list",
            new SqlParameter("@retreat", hdRet.Value),
            new SqlParameter("@cash_type", hdType.Value),
            new SqlParameter("@excel_yn", "N"));

        string _t_nm_1 = string.Empty;
        string _t_nm_2 = string.Empty;
        string _t_nm_3 = string.Empty;

        switch (hdType.Value)
        {
            case "1":
                _t_nm_1 = "수입";
                _t_nm_2 = "금액";
                _t_nm_3 = "증빙자료";
                break;
            case "2":
                _t_nm_1 = "지출";
                _t_nm_2 = "비용";
                _t_nm_3 = "영수증";
                break;
            default:
                _t_nm_1 = string.Empty;
                _t_nm_2 = string.Empty;
                _t_nm_3 = string.Empty;
                break;
        }


        if (ds.Tables[0].Rows.Count > 0)
        {
            StringBuilder sb = new StringBuilder();
            string _table_html = string.Empty;

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                _table_html = _table_html + @"
                            <div style='margin-top: 20mm; page-break-after: always;'>
                                <table class='print-data-table'>
                                    <tr>
                                        <th class='nowrap' style='width:120px;'>연번</th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["NUM"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class='nowrap'>" + _t_nm_1 + @"항목 </th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["payment_type_nm"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class='nowrap'>" + _t_nm_1 + @"내용</th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["payment_item"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class='nowrap'>" + _t_nm_1 + _t_nm_2 + @"</th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["payment_format"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class='nowrap'>" + _t_nm_1 + @"일자</th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["payment_dt"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                ";

                if (!ds.Tables[0].Rows[i]["file_nm"].ToString().Trim().Equals(string.Empty))
                {
                    _table_html = _table_html + @"
                                    <tr>
                                        <th class='nowrap'>" + _t_nm_3 + @"</th>
                                        <td>
                                            <img src='" + ds.Tables[0].Rows[i]["file_url"].ToString().Trim() + @"' alt='" + _t_nm_3 + @"' class='img-fluid print_img' />
                                        </td>
                                    </tr>
                ";
                }


                _table_html = _table_html + @"
                                    <tr>
                                        <th class='nowrap'>비고</th>
                                        <td>
                                            " + ds.Tables[0].Rows[i]["payment_item_desc"].ToString().Trim() + @"
                                        </td>
                                    </tr>
                                </table>
                            </div>

                ";
            }

            sb.Append(_table_html);

            divPrint.InnerHtml = sb.ToString();
        }
    }

}
