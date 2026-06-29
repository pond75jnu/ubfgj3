using System;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Data;
using System.Data.SqlClient;

public partial class usercontrol_page_header : System.Web.UI.UserControl
{    
    string _menu_path = CodeHelper.GetCurrentMenuPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            Breadcrumb();
            SetPastRetreatNotice();
        }
    }

    protected void Breadcrumb()
    {
        try
        {
            DataSet ds1 = null;
            DataSet ds2 = null;

            StringBuilder sb = new StringBuilder();
            sb.Append("");
            sb.Append("<nav aria-label='breadcrumb'>");

            ds1 = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_menu_breadcrumb_current_sel",
                new SqlParameter("@Path", _menu_path));

            if (ds1.Tables[0].Rows.Count > 0)
            {
                sb.Append("<ol class='site-breadcrumb'>");
                sb.Append("<li><a href='/' class='site-breadcrumb-link'>Home</a></li>");
                if (ds1.Tables[0].Rows[0]["menu_depth"].ToString().Equals("1"))
                {
                    ds2 = EfStoredProcedure.ExecuteDataSet(
                        "ubfgj3.dbo.SP_menu_by_seq_sel",
                        new SqlParameter("@Seq", ds1.Tables[0].Rows[0]["parent_seq"].ToString()));

                    sb.Append("<li><a href='" + CodeHelper.ToCanonicalUrl(ds2.Tables[0].Rows[0]["menu_path"].ToString()) + @"' class='site-breadcrumb-link'>" + ds2.Tables[0].Rows[0]["menu_nm"].ToString() + @"</a></li>");
                    sb.Append("<li class='is-active' aria-current='page'>" + ds1.Tables[0].Rows[0]["menu_nm"].ToString() + @"</li>");
                }
                else if (ds1.Tables[0].Rows[0]["menu_depth"].ToString().Equals("0"))
                {
                    sb.Append("<li class='is-active' aria-current='page'>" + ds1.Tables[0].Rows[0]["menu_nm"].ToString() + @"</li>");
                }
                sb.Append("</ol>");
            }

            sb.Append("</nav>");

            divNavBreadcrumb.InnerHtml = sb.ToString();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('breadcrumb 로딩 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
        
    }

    protected void SetPastRetreatNotice()
    {
        try
        {
            if (!ShouldShowPastRetreatNotice())
                return;

            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_get_list");
            if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return;

            DataRow latestRetreat = ds.Tables[0].Rows[0];
            DataRow activeRetreat = null;

            foreach (DataRow row in ds.Tables[0].Rows)
            {
                if (row["retreat_yn"].ToString().Trim().Equals("Y", StringComparison.OrdinalIgnoreCase))
                {
                    activeRetreat = row;
                    break;
                }
            }

            if (activeRetreat == null)
                return;

            string latestSeq = latestRetreat["seq"].ToString().Trim();
            string activeSeq = activeRetreat["seq"].ToString().Trim();

            if (!activeSeq.Equals(latestSeq))
            {
                pnlPastRetreatNotice.Visible = true;
                lblPastRetreatNotice.Text = "과거 수양회(" + activeRetreat["retreat_name"].ToString().Trim() + ") 내용으로 보는 중입니다.";
            }
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 안내 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected bool ShouldShowPastRetreatNotice()
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_menu_breadcrumb_current_sel",
            new SqlParameter("@Path", _menu_path));

        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return true;

        if (!ds.Tables[0].Rows[0]["menu_depth"].ToString().Equals("1"))
            return true;

        DataSet parentMenu = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_menu_by_seq_sel",
            new SqlParameter("@Seq", ds.Tables[0].Rows[0]["parent_seq"].ToString()));

        if (parentMenu.Tables.Count == 0 || parentMenu.Tables[0].Rows.Count == 0)
            return true;

        string parentMenuName = parentMenu.Tables[0].Rows[0]["menu_nm"].ToString().Trim();

        return !parentMenuName.Equals("시스템") && !parentMenuName.Equals("My정보수정", StringComparison.OrdinalIgnoreCase);
    }
}
