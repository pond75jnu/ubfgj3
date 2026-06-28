using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

public partial class manage_groups : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = HttpContext.Current.Request.Url.AbsolutePath.ToLower();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        LoadRetreats();

        #region 페이지모드 체크
        if (!string.IsNullOrEmpty(Request.QueryString["mode"]))
        {

            if (Request.QueryString["mode"].ToLower() == "write")
            {
                PageMode("WRITE");
            }
            else if (Request.QueryString["mode"].ToLower() == "modify")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["seq"]))
                {
                    hdSeq.Value = Request.QueryString["seq"].Trim();
                    PageMode("MODIFY");
                }
                else
                    Response.Redirect("/manage/groups.aspx", false);
            }
            else
            {
                if(!Page.IsPostBack)
                {
                    PageMode("LIST");
                }
                
            }
                
        }
        else
        {
            if (!Page.IsPostBack)
            {
                PageMode("LIST");
            }
        }
            
        #endregion
    }

    protected void PageMode(string _mode)
    {
        switch (_mode)
        {                       
            case "LIST":                
                divList.Visible = true;
                divWriteModify.Visible = false;

                GetList();

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                break;
            case "WRITE":                
                divList.Visible = false;
                divWriteModify.Visible = true;

                btnNew.Visible = false;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                lblWriteModeTitle.Text = "신규입력";
                break;
            case "MODIFY":                
                divList.Visible = false;
                divWriteModify.Visible = true;

                GetDetail();

                btnNew.Visible = false;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = true;

                lblWriteModeTitle.Text = "수정";
                break;
            default:                
                divList.Visible = true;
                divWriteModify.Visible = false;

                GetList();

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                break;
        }
    }

    protected void LoadRetreats()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_manage_retreat_recent_sel");

            if (ds.Tables[0].Rows.Count > 0)
            {
                ddl_retreat.DataSource = ds;
                ddl_retreat.DataBind();

                if (!CodeHelper.RetreatCode.Equals(string.Empty))
                    ddl_retreat.SelectedValue = CodeHelper.RetreatCode;
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

    protected void GetList()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_manage_group_list_sel",
                new SqlParameter("@Retreat", SqlDbType.Int) { Value = Convert.ToInt32(ddl_retreat.SelectedValue) });

            gvList.DataSource = ds;
            gvList.DataBind();

            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회 목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_manage_group_detail_sel",
                new SqlParameter("@Seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (ds.Tables[0].Rows.Count > 0)
            {
                txtBelong.Text = ds.Tables[0].Rows[0]["belong_nm"].ToString().Trim();
                txtManager.Text = ds.Tables[0].Rows[0]["manager"].ToString().Trim();
                ddl_use_yn.SelectedValue = ds.Tables[0].Rows[0]["use_yn"].ToString();
            }
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string seq = hdSeq.Value.ToString().Trim();
            string belongNm = seq.Equals(string.Empty) ? txtBelong.Text.Trim() : hdBelong.Value.ToString().Trim();

            DataSet ds1 = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_manage_group_duplicate_sel",
                new SqlParameter("@BelongNm", belongNm),
                new SqlParameter("@Retreat", SqlDbType.Int)
                {
                    Value = seq.Equals(string.Empty)
                        ? (object)Convert.ToInt32(ddl_retreat.SelectedValue)
                        : DBNull.Value
                },
                new SqlParameter("@Seq", SqlDbType.Int) { Value = seq.Equals(string.Empty) ? (object)DBNull.Value : Convert.ToInt32(seq) });

            if (ds1.Tables[0].Rows.Count > 0)
            {
                CodeHelper.Redirect("이미 사용중인 요회명입니다.", "/manage/groups.aspx");

            }
            else
            {
                if (hdSeq.Value.ToString().Trim().Equals(string.Empty))
                {
                    EfStoredProcedure.ExecuteNonQuery(
                        "ubfgj3.dbo.SP_manage_group_ins",
                        new SqlParameter("@BelongNm", txtBelong.Text.Trim()),
                        new SqlParameter("@Manager", txtManager.Text.Trim()),
                        new SqlParameter("@Retreat", SqlDbType.Int) { Value = Convert.ToInt32(ddl_retreat.SelectedValue) },
                        new SqlParameter("@UseYn", hdUseYN.Value),
                        new SqlParameter("@LoginId", _login_id),
                        new SqlParameter("@UserIp", CodeHelper.GetUserIP));

                    CodeHelper.Redirect("저장하였습니다.", "/manage/groups.aspx");
                }
                else
                {
                    EfStoredProcedure.ExecuteNonQuery(
                        "ubfgj3.dbo.SP_manage_group_upd",
                        new SqlParameter("@Seq", SqlDbType.Int) { Value = Convert.ToInt32(seq) },
                        new SqlParameter("@BelongNm", hdBelong.Value.ToString().Trim()),
                        new SqlParameter("@Manager", hdManager.Value.ToString().Trim()),
                        new SqlParameter("@UseYn", hdUseYN.Value),
                        new SqlParameter("@LoginId", _login_id),
                        new SqlParameter("@UserIp", CodeHelper.GetUserIP));

                    CodeHelper.Redirect("수정하였습니다.", "/manage/groups.aspx?mode=modify&seq=" + hdSeq.Value.ToString().Trim());
                }
                
            }

            

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('저장 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }

    }

    protected void btnDel_Click(object sender, EventArgs e)
    {
        try
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_manage_group_del",
                new SqlParameter("@Seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value) });

            CodeHelper.Redirect("삭제하였습니다!", "/manage/groups.aspx");
        }
        catch (Exception ex)
        {

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('삭제 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }


    protected void gvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascript:detailview_group('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }

    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetList();
    }

}
