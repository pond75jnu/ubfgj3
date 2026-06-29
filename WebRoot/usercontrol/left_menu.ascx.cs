using System;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Data;
using System.Data.SqlClient;

public partial class usercontrol_left_menu : System.Web.UI.UserControl
{
    string _auth = UserInfo.UserRole.ToLower();
    string _path = CodeHelper.GetCurrentCanonicalPath();
    string _menu_path = CodeHelper.GetCurrentMenuPath();

    string m_Retreat = string.Empty;
    string m_Belong = string.Empty;

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

    string _expenses_total_cnt = string.Empty;
    string _expenses_total_cost = string.Empty;

    string _income_regist_total_cnt = string.Empty;
    string _income_regist_total_cost = string.Empty;

    string _income_total_cnt = string.Empty;
    string _income_total_cost = string.Empty;

    public string mRetreat
    {
        get { return m_Retreat; }
        set { m_Retreat = value; }
    }

    public string mBelong
    {
        get { return m_Belong; }
        set { m_Belong = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        

        if (!Page.IsPostBack)
        {

            if (_path.Equals("/group/usermanage") || _path.Equals("/staff/registatus"))
                GetRegistInfo();

            if (_path.Equals("/staff/expenses"))
                GetExpenses();

            if (_path.Equals("/staff/income"))
                GetIncome();

            SetMenu();

        }
    }

    protected void SetMenu()
    {
        try
        {
            
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_menu_left_by_path_auth_sel",
                new SqlParameter("@Path", _menu_path),
                new SqlParameter("@Auth", _auth));



            StringBuilder sb = new StringBuilder();
            sb.Append("<nav class='site-side-card' aria-label='보조 메뉴'><ul class='site-side-list'>");

            if (ds.Tables[0].Rows.Count > 0)
            {
                string _menu_nm = string.Empty;
                string _menu_link = string.Empty;

                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    _menu_nm = ds.Tables[0].Rows[i]["menu_nm"].ToString().Trim();
                    _menu_link = CodeHelper.ToCanonicalUrl(ds.Tables[0].Rows[i]["menu_path"].ToString().Trim().ToLower());

                    if (CodeHelper.ToCanonicalPath(ds.Tables[0].Rows[i]["menu_path"].ToString().Trim()).Equals(_path))
                        sb.Append("<li><a href='" + _menu_link + @"' class='site-side-link is-active'><span>" + _menu_nm + @"</span></a></li>");
                    else
                        sb.Append("<li><a href='" + _menu_link + @"' class='site-side-link'><span>" + _menu_nm + @"</span></a></li>");

                }
            }

            sb.Append("</ul></nav>");

            if (_path.Equals("/group/usermanage") || _path.Equals("/staff/registatus"))
            {
                string _caption = !m_Belong.Equals("%") ? CodeHelper.GetGroupName(m_Belong) + " 등록현황" : "전체 등록현황";
                string _table_html = @"

    <table class='site-summary-table'>
        <caption>" + _caption + @"</caption>
        <thead>
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
            <tr class='site-summary-total'>
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
                    " + _str_total_P+ @"
                </td>
                <td class='nowrap txt_center'>
                    " + _str_total_N+ @"
                </td>
            </tr>
        </tbody>
    </table>
                ";

                if (_path.Equals("/group/usermanage"))
                    sb = new StringBuilder(); //구성원·등록관리 메뉴인 경우 왼쪽 서브메뉴 필요없음

                sb.Append(_table_html);
            }

            if (_path.Equals("/staff/expenses"))
            {
                string _table_expenses_html = @"
    <table class='site-summary-table'>
        <caption>전체 지출현황</caption>
        <thead>
            <tr>
                <th class='nowrap txt_center'>
                    지출건수
                </th>
                <th class='nowrap txt_center'>
                    지출금액
                </th>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td class='nowrap txt_center'>
                    <strong>" + _expenses_total_cnt + @"</strong>
                </td>
                <td class='nowrap txt_center'>
                    <strong>" + _expenses_total_cost + @"</strong>
                </td>
            </tr>
        </tbody>
    </table>
                ";

                sb.Append(_table_expenses_html);
            }

            if (_path.Equals("/staff/income"))
            {
                string _table_income_html = @"
    <table class='site-summary-table'>
        <caption>수양회비 (부분등록 포함)</caption>
        <thead>
            <tr>
                <th class='nowrap txt_center'>
                    등록건수
                </th>
                <th class='nowrap txt_center'>
                    수양회비
                </th>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td class='nowrap txt_center'>
                    <strong>" + _income_regist_total_cnt + @"</strong>
                </td>
                <td class='nowrap txt_center'>
                    <strong>" + _income_regist_total_cost + @"</strong>
                </td>
            </tr>
        </tbody>
    </table>

    <table class='site-summary-table'>
        <caption>수입현황 (수양회비 제외)</caption>
        <thead>
            <tr>
                <th class='nowrap txt_center'>
                    수입건수
                </th>
                <th class='nowrap txt_center'>
                    수입금액
                </th>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td class='nowrap txt_center'>
                    <strong>" + _income_total_cnt + @"</strong>
                </td>
                <td class='nowrap txt_center'>
                    <strong>" + _income_total_cost + @"</strong>
                </td>
            </tr>
        </tbody>
    </table>
                ";

                sb.Append(_table_income_html);
            }

            divLeftMenu.InnerHtml = sb.ToString();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('사이드메뉴 로딩 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }

    }

    protected void GetExpenses()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_payment_expenses_summary_sel",
                new SqlParameter("@Retreat", m_Retreat));

            if (ds.Tables[0].Rows.Count > 0)
            {
                _expenses_total_cnt = ds.Tables[0].Rows[0]["cnt"].ToString() + " 건";
                _expenses_total_cost = ds.Tables[0].Rows[0]["total_payment_format"].ToString();
            }
            else
            {
                _expenses_total_cnt = "0 건";
                _expenses_total_cost = "0 원";
            }
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('총 지출금액 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetIncome()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_income_summary_sel",
                new SqlParameter("@Retreat", m_Retreat));

            if (ds.Tables[0].Rows.Count > 0)
            {
                _income_regist_total_cnt = ds.Tables[0].Rows[0]["cnt"].ToString() + " 건";
                _income_regist_total_cost = ds.Tables[0].Rows[0]["total_regist_format"].ToString();
            }
            else
            {
                _income_regist_total_cnt = "0 건";
                _income_regist_total_cost = "0 원";
            }

            if (ds.Tables[1].Rows.Count > 0)
            {
                _income_total_cnt = ds.Tables[1].Rows[0]["cnt"].ToString() + " 건";
                _income_total_cost = ds.Tables[1].Rows[0]["total_payment_format"].ToString();
            }
            else
            {
                _income_regist_total_cnt = "0 건";
                _income_regist_total_cost = "0 원";
            }
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('총 지출금액 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetRegistInfo()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_regist_info_sel",
                new SqlParameter("@Retreat", m_Retreat),
                new SqlParameter("@Belong", m_Belong));

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

            string _message_01 = string.Empty;
            string _message_02 = string.Empty;

            if (ds.Tables[0].Rows.Count > 0)
            {
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    if (ds.Tables[0].Rows[i]["simple_usertype_nm"].ToString().Equals("reader"))
                        _reader = _reader + 1;
                    else
                        _lamb = _lamb + 1;

                    if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("lamb_complete"))
                        _lamb_c_regi = _lamb_c_regi + 1;
                    else if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("reader_complete"))
                        _reader_c_regi = _reader_c_regi + 1;
                    else if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("lamb_no_complete"))
                        _lamb_n_regi = _lamb_n_regi + 1;
                    else if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("reader_no_complete"))
                        _reader_n_regi = _reader_n_regi + 1;
                    else if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("lamb_p_complete"))
                        _lamb_p_regi = _lamb_p_regi + 1;
                    else if (ds.Tables[0].Rows[i]["regi_type"].ToString().Equals("reader_p_complete"))
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


        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('등록현황 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }
    
}
