using System;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class staff_status : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        #region 쿼리스트링 체크
        if (!string.IsNullOrEmpty(Request.QueryString["mode"]))
        {
            if (!Request.QueryString["mode"].ToString().Trim().Equals("1")
                && !Request.QueryString["mode"].ToString().Trim().Equals("2")
                && !Request.QueryString["mode"].ToString().Trim().Equals("3"))
                hdMode.Value = "1";
            else
                hdMode.Value = Request.QueryString["mode"].ToString().Trim();
        }
        else
            hdMode.Value = "1";
        #endregion

        divStatusPage.Attributes["class"] = "site-panel site-status-page site-status-mode-" + hdMode.Value;

        if (!Page.IsPostBack)
        {
            LoadRetreats();

            try
            {

                if (hdMode.Value.ToString().Equals("1"))
                {
                    GetStatusRegist();

                    divContents.Visible = true;
                    divContents2.Visible = false;
                    divContents3.Visible = false;
                }
                else if (hdMode.Value.ToString().Equals("2"))
                {
                    GetStatusPay();

                    divContents.Visible = false;
                    divContents2.Visible = true;
                    divContents3.Visible = false;
                }
                else
                {
                    GetAttends();

                    divContents.Visible = false;
                    divContents2.Visible = false;
                    divContents3.Visible = true;
                }
            }
            catch (Exception ex)
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('현황 조회 도중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
            }
        }
    }

    protected void LoadRetreats()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_get");

            if (ds.Tables[0].Rows.Count > 0)
            {
                ddl_retreat.DataSource = ds;
                ddl_retreat.DataBind();

                if (!CodeHelper.RetreatCode.Equals(string.Empty))
                    ddl_retreat.SelectedValue = CodeHelper.RetreatCode;

                ddl_retreat.Enabled = false;
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보가 없습니다. (관리자 문의)');</script>");
                return;
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetStatusRegist()
    {
        StringBuilder sb1 = new StringBuilder();
        string _html_tab = @"
                    <ul class='site-tabs'>
                        <li>
                            <a class='site-tab-link is-active' aria-current='page' href='javascript:;'>등록현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link' href='/staff/status?mode=2'>수입·지출현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link' href='/staff/status?mode=3'>참석현황</a>
                        </li>
                    </ul>
        ";

        sb1.Append(_html_tab);
        divTab.InnerHtml = sb1.ToString();

        StringBuilder sb2 = new StringBuilder();

        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_status_group_targets",
            new SqlParameter("@RETREAT", ddl_retreat.SelectedValue));

        DataSet dsLst = null;
        string _html_contents = string.Empty;

        #region 변수모음
        int _reader = 0;
        int _reader_p_regi = 0;
        int _reader_c_regi = 0;
        int _reader_n_regi = 0;
        int _lamb = 0;
        int _lamb_p_regi = 0;
        int _lamb_c_regi = 0;
        int _lamb_n_regi = 0;
        int _all = 0;
        int _all_p_regi = 0;
        int _all_c_regi = 0;
        int _all_n_regi = 0;

        string _str_reader_all = string.Empty;
        string _str_reader_C = string.Empty;
        string _str_reader_P = string.Empty;
        string _str_reader_N = string.Empty;

        string _str_lamb_all = string.Empty;
        string _str_lamb_C = string.Empty;
        string _str_lamb_P = string.Empty;
        string _str_lamb_N = string.Empty;

        string _str_total_all = string.Empty;
        string _str_total_C = string.Empty;
        string _str_total_P = string.Empty;
        string _str_total_N = string.Empty;
        string _caption_title = string.Empty;
        #endregion

        if (ds.Tables[0].Rows.Count > 0)
        {
            _html_contents = "<div class='site-status-summary-grid'>";

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                #region 요회별 조회
                if (!ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _caption_title = ds.Tables[0].Rows[i]["belong_nm"].ToString();
                }
                else
                {
                    _caption_title = "전체";
                }
                #endregion

                dsLst = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_status_regist_get_members",
                    new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                    new SqlParameter("@BELONG", ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0") ? (object)DBNull.Value : ds.Tables[0].Rows[i]["seq"].ToString().Trim()));


                _html_contents = _html_contents + "<div class='site-status-summary-cell'>";

                #region 자료(등록현황) 매핑
                if (dsLst.Tables[0].Rows.Count > 0)
                {
                    for (int j = 0; j < dsLst.Tables[0].Rows.Count; j++)
                    {
                        if (dsLst.Tables[0].Rows[j]["simple_usertype_nm"].ToString().Equals("reader"))
                            _reader = _reader + 1;
                        else
                            _lamb = _lamb + 1;

                        if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("lamb_complete"))
                            _lamb_c_regi = _lamb_c_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("reader_complete"))
                            _reader_c_regi = _reader_c_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("lamb_no_complete"))
                            _lamb_n_regi = _lamb_n_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("reader_no_complete"))
                            _reader_n_regi = _reader_n_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("lamb_p_complete"))
                            _lamb_p_regi = _lamb_p_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["regi_type"].ToString().Equals("reader_p_complete"))
                            _reader_p_regi = _reader_p_regi + 1;
                    }

                    _all = _reader + _lamb;
                    _all_c_regi = _reader_c_regi + _lamb_c_regi;
                    _all_p_regi = _reader_p_regi + _lamb_p_regi;
                    _all_n_regi = _reader_n_regi + _lamb_n_regi;

                    if (_reader > 0)
                    {
                        _str_reader_all = _reader.ToString() + " 명";
                        _str_reader_C = _reader_c_regi.ToString() + " 명";
                        _str_reader_P = _reader_p_regi.ToString() + " 명";
                        _str_reader_N = _reader_n_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_reader_all = "0 명";
                        _str_reader_C = "0 명";
                        _str_reader_P = "0 명";
                        _str_reader_N = "0 명";
                    }


                    if (_lamb > 0)
                    {
                        _str_lamb_all = _lamb.ToString() + " 명";
                        _str_lamb_C = _lamb_c_regi.ToString() + " 명";
                        _str_lamb_P = _lamb_p_regi.ToString() + " 명";
                        _str_lamb_N = _lamb_n_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_lamb_all = "0 명";
                        _str_lamb_C = "0 명";
                        _str_lamb_P = "0 명";
                        _str_lamb_N = "0 명";
                    }

                    if (_all > 0)
                    {
                        _str_total_all = _all.ToString() + " 명";
                        _str_total_C = _all_c_regi.ToString() + " 명";
                        _str_total_P = _all_p_regi.ToString() + " 명";
                        _str_total_N = _all_n_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_total_all = "0 명";
                        _str_total_C = "0 명";
                        _str_total_P = "0 명";
                        _str_total_N = "0 명";
                    }
                }
                else
                {
                    _str_reader_all = "0 명";
                    _str_reader_C = "0 명";
                    _str_reader_P = "0 명";
                    _str_reader_N = "0 명";

                    _str_lamb_all = "0 명";
                    _str_lamb_C = "0 명";
                    _str_lamb_P = "0 명";
                    _str_lamb_N = "0 명";

                    _str_total_all = "0 명";
                    _str_total_C = "0 명";
                    _str_total_P = "0 명";
                    _str_total_N = "0 명";
                }
                #endregion

                #region 등록현환 html

                if (ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _html_contents = _html_contents + @"
                    <table class='site-summary-table'>
                        <caption>" + _caption_title + @"</caption>
                        <thead>
                    ";
                }
                else
                {
                    _html_contents = _html_contents + @"
                    <table class='site-summary-table'>
                        <caption><a href='/group/usermanage?ret=" + ddl_retreat.SelectedValue + @"&belong=" + ds.Tables[0].Rows[i]["seq"].ToString() + @"&reg=%'>" + _caption_title + @"</a></caption>
                        <thead>
                    ";
                }


                _html_contents = _html_contents + @"
                            <tr>
                                <th class='nowrap txt_center'>
                                    구분
                                </th>
                                <th class='nowrap txt_center'>
                                    소계
                                </th>
                                <th class='nowrap txt_center'>
                                    완전등록
                                </th>
                                <th class='nowrap txt_center'>
                                    부분등록
                                </th>
                                <th class='nowrap txt_center'>
                                    미등록
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class='nowrap txt_center'>
                                    <strong>리더</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_P + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_N + @"
                                </td>
                            </tr>
                            <tr>
                                <td class='nowrap txt_center'>
                                    <strong>양</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_P + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_N + @"
                                </td>
                            </tr>
                           ";
                if (ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _html_contents = _html_contents + @"<tr class='site-summary-total'>
                                <td class='nowrap txt_center'>
                                    <strong>계</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_all + @"</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_C + @"</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_P + @"</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_N + @"</strong>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    ";
                }
                else
                {
                    _html_contents = _html_contents + @"<tr class='site-summary-total'>
                                <td class='nowrap txt_center'>
                                    <strong>계</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_P + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_N + @"
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    ";
                }



                #endregion


                _html_contents = _html_contents + "</div>";

                _reader = 0;
                _reader_p_regi = 0;
                _reader_c_regi = 0;
                _reader_n_regi = 0;
                _lamb = 0;
                _lamb_p_regi = 0;
                _lamb_c_regi = 0;
                _lamb_n_regi = 0;
                _all = 0;
                _all_p_regi = 0;
                _all_c_regi = 0;
                _all_n_regi = 0;
            }

            _html_contents = _html_contents + "</div>";
        }

        sb2.Append(_html_contents);

        divContents.InnerHtml = sb2.ToString();
    }

    protected void GetStatusPay()
    {
        decimal _income = -1;
        decimal _expenses = -1;

        StringBuilder sb1 = new StringBuilder();
        string _html_tab2 = @"
                    <ul class='site-tabs'>
                        <li>
                            <a class='site-tab-link' href='/staff/status'>등록현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link is-active' aria-current='page' href='javascript:;'>수입·지출현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link' href='/staff/status?mode=3'>참석현황</a>
                        </li>
                    </ul>
        ";

        sb1.Append(_html_tab2);
        divTab.InnerHtml = sb1.ToString();

        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_income_get_list_status",
            new SqlParameter("@retreat", ddl_retreat.SelectedValue),
            new SqlParameter("@cash_type", 1));

        if (ds.Tables[1].Rows.Count > 0)
        {
            _income = Convert.ToDecimal(ds.Tables[1].Rows[0]["payment_all"].ToString().Trim());
        }

        gvList.DataSource = ds.Tables[0];
        gvList.DataBind();

        ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_income_get_list_status",
            new SqlParameter("@retreat", ddl_retreat.SelectedValue),
            new SqlParameter("@cash_type", 2));

        if (ds.Tables[1].Rows.Count > 0)
        {
            _expenses = Convert.ToDecimal(ds.Tables[1].Rows[0]["payment_all"].ToString().Trim());
        }

        gvList2.DataSource = ds.Tables[0];
        gvList2.DataBind();

        if (!_income.Equals(-1) && !_expenses.Equals(-1))
        {
            decimal _result = _income - _expenses;
            lblResult.Text = "총 결산 : " + String.Format("{0:#,0}", _result) + " 원";

            if (_result >= 0)
                lblResult.ForeColor = System.Drawing.Color.Blue;
            else
                lblResult.ForeColor = System.Drawing.Color.Red;
        }

    }

    protected void GetAttends()
    {
        StringBuilder sb1 = new StringBuilder();
        string _html_tab3 = @"
                    <ul class='site-tabs'>
                        <li>
                            <a class='site-tab-link' href='/staff/status'>등록현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link' href='/staff/status?mode=2'>수입·지출현황</a>
                        </li>
                        <li>
                            <a class='site-tab-link is-active' aria-current='page' href='javascript:;'>참석현황</a>
                        </li>
                    </ul>
        ";

        sb1.Append(_html_tab3);
        divTab.InnerHtml = sb1.ToString();

        StringBuilder sb2 = new StringBuilder();

        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_status_group_targets",
            new SqlParameter("@RETREAT", ddl_retreat.SelectedValue));

        DataSet dsLst = null;
        string _html_contents = string.Empty;

        #region 변수모음
        int _reader = 0;
        int _reader_p_regi = 0;
        int _reader_c_regi = 0;
        int _lamb = 0;
        int _lamb_p_regi = 0;
        int _lamb_c_regi = 0;
        int _all = 0;
        int _all_p_regi = 0;
        int _all_c_regi = 0;

        string _str_reader_all = string.Empty;
        string _str_reader_C = string.Empty;
        string _str_reader_P = string.Empty;

        string _str_lamb_all = string.Empty;
        string _str_lamb_C = string.Empty;
        string _str_lamb_P = string.Empty;

        string _str_total_all = string.Empty;
        string _str_total_C = string.Empty;
        string _str_total_P = string.Empty;
        string _caption_title = string.Empty;
        #endregion

        if (ds.Tables[0].Rows.Count > 0)
        {
            _html_contents = "<div class='site-status-summary-grid'>";

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                #region 요회별 조회
                if (!ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _caption_title = ds.Tables[0].Rows[i]["belong_nm"].ToString();
                }
                else
                {
                    _caption_title = "전체";
                }
                #endregion

                dsLst = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_status_attend_get_members",
                    new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                    new SqlParameter("@BELONG", ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0") ? (object)DBNull.Value : ds.Tables[0].Rows[i]["seq"].ToString().Trim()));


                _html_contents = _html_contents + "<div class='site-status-summary-cell'>";

                #region 자료(등록현황) 매핑
                if (dsLst.Tables[0].Rows.Count > 0)
                {
                    for (int j = 0; j < dsLst.Tables[0].Rows.Count; j++)
                    {
                        if (dsLst.Tables[0].Rows[j]["attend_type"].ToString().Equals("lamb_full_attend"))
                            _lamb_c_regi = _lamb_c_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["attend_type"].ToString().Equals("reader_full_attend"))
                            _reader_c_regi = _reader_c_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["attend_type"].ToString().Equals("lamb_part_attend"))
                            _lamb_p_regi = _lamb_p_regi + 1;
                        else if (dsLst.Tables[0].Rows[j]["attend_type"].ToString().Equals("reader_part_attend"))
                            _reader_p_regi = _reader_p_regi + 1;
                    }

                    _reader = _reader_c_regi + _reader_p_regi;
                    _lamb = _lamb_c_regi + _lamb_p_regi;

                    _all = _reader + _lamb;
                    _all_c_regi = _reader_c_regi + _lamb_c_regi;
                    _all_p_regi = _reader_p_regi + _lamb_p_regi;

                    if (_reader > 0)
                    {
                        _str_reader_all = _reader.ToString() + " 명";
                        _str_reader_C = _reader_c_regi.ToString() + " 명";
                        _str_reader_P = _reader_p_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_reader_all = "0 명";
                        _str_reader_C = "0 명";
                        _str_reader_P = "0 명";
                    }


                    if (_lamb > 0)
                    {
                        _str_lamb_all = _lamb.ToString() + " 명";
                        _str_lamb_C = _lamb_c_regi.ToString() + " 명";
                        _str_lamb_P = _lamb_p_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_lamb_all = "0 명";
                        _str_lamb_C = "0 명";
                        _str_lamb_P = "0 명";
                    }

                    if (_all > 0)
                    {
                        _str_total_all = _all.ToString() + " 명";
                        _str_total_C = _all_c_regi.ToString() + " 명";
                        _str_total_P = _all_p_regi.ToString() + " 명";
                    }
                    else
                    {
                        _str_total_all = "0 명";
                        _str_total_C = "0 명";
                        _str_total_P = "0 명";
                    }
                }
                else
                {
                    _str_reader_all = "0 명";
                    _str_reader_C = "0 명";
                    _str_reader_P = "0 명";

                    _str_lamb_all = "0 명";
                    _str_lamb_C = "0 명";
                    _str_lamb_P = "0 명";

                    _str_total_all = "0 명";
                    _str_total_C = "0 명";
                    _str_total_P = "0 명";
                }
                #endregion

                #region 참석현환 html

                if (ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _html_contents = _html_contents + @"
                    <table class='site-summary-table'>
                        <caption>" + _caption_title + @"</caption>
                        <thead>
                    ";
                }
                else
                {
                    _html_contents = _html_contents + @"
                    <table class='site-summary-table'>
                        <caption><a href='/group/usermanage?ret=" + ddl_retreat.SelectedValue + @"&belong=" + ds.Tables[0].Rows[i]["seq"].ToString() + @"&reg=%'>" + _caption_title + @"</a></caption>
                        <thead>
                    ";
                }


                _html_contents = _html_contents + @"
                            <tr>
                                <th class='nowrap txt_center'>
                                    구분
                                </th>
                                <th class='nowrap txt_center'>
                                    소계
                                </th>
                                <th class='nowrap txt_center'>
                                    완전참석
                                </th>
                                <th class='nowrap txt_center'>
                                    부분참석
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class='nowrap txt_center'>
                                    <strong>리더</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_reader_P + @"
                                </td>
                            </tr>
                            <tr>
                                <td class='nowrap txt_center'>
                                    <strong>양</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_lamb_P + @"
                                </td>
                            </tr>
                           ";
                if (ds.Tables[0].Rows[i]["belong_nm"].ToString().Trim().Equals("0"))
                {
                    _html_contents = _html_contents + @"<tr class='site-summary-total'>
                                <td class='nowrap txt_center'>
                                    <strong>계</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_all + @"</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_C + @"</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    <strong>" + _str_total_P + @"</strong>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    ";
                }
                else
                {
                    _html_contents = _html_contents + @"<tr class='site-summary-total'>
                                <td class='nowrap txt_center'>
                                    <strong>계</strong>
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_all + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_C + @"
                                </td>
                                <td class='nowrap txt_center'>
                                    " + _str_total_P + @"
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    ";
                }



                #endregion


                _html_contents = _html_contents + "</div>";

                _reader = 0;
                _reader_p_regi = 0;
                _reader_c_regi = 0;
                _lamb = 0;
                _lamb_p_regi = 0;
                _lamb_c_regi = 0;
                _all = 0;
                _all_p_regi = 0;
                _all_c_regi = 0;
            }

            _html_contents = _html_contents + "</div>";
        }

        sb2.Append(_html_contents);

        divContents3.InnerHtml = sb2.ToString();
    }


    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (hdMode.Value.ToString().Equals("1"))
            GetStatusRegist();
        else if (hdMode.Value.ToString().Equals("2"))
            GetStatusPay();
        else
            GetAttends();
    }

    protected void gvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[0].Text.Trim().Equals("총계"))
            {
                e.Row.Font.Bold = true;
            }
        }
    }

    protected void gvList2_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[0].Text.Trim().Equals("총계"))
            {
                e.Row.Font.Bold = true;
            }
        }
    }



}
