using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

public partial class staff_retreatdues : System.Web.UI.Page
{

    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);
        

        if (!Page.IsPostBack)
        {
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
                        Response.Redirect("/staff/retreatdues", false);
                }
                else
                    PageMode("LIST");
            }
            else
                PageMode("LIST");
            #endregion
        }


    }

    protected void PageMode(string _mode)
    {
        switch (_mode)
        {
            case "LIST":
                divList.Visible = true;
                divWriteModify.Visible = false;

                GetList();

                if (ddl_retreat.Items.Count > 0)
                    btnNew.Visible = true;
                else
                    btnNew.Visible = false;
                    
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
                "ubfgj3.dbo.SP_staff_retreat_get_list",
                new SqlParameter("@top_count", SqlDbType.Int) { Value = 10 },
                new SqlParameter("@active_only", SqlDbType.Bit) { Value = false });

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
                "ubfgj3.dbo.SP_staff_retreatdues_get_list",
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(ddl_retreat.SelectedValue) });

            gvList.DataSource = ds;
            gvList.DataBind();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회비 구분 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_retreatdues_get_detail",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (ds.Tables[0].Rows.Count > 0)
            {
                txtRetreatDuesNM.Text = ds.Tables[0].Rows[0]["dues_nm"].ToString().Trim();
                txtRetreatDues.Text = String.Format("{0:#,0}", Convert.ToDecimal(ds.Tables[0].Rows[0]["dues"]));
                txtRetreatDuesDesc.Text = ds.Tables[0].Rows[0]["dues_desc"].ToString().Trim();
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SetData(string mode)
    {
        decimal _dues = CodeHelper.ParseWholeWon(hdRetreatDues.Value, "회비");

        if (mode.Equals("C"))
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_retreatdues_insert",
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(hdRetreat.Value.Trim()) },
                new SqlParameter("@dues_nm", SqlDbType.NVarChar, 200) { Value = hdRetreatDuesNM.Value.Trim().Replace("\"","").Replace("'","") },
                new SqlParameter("@dues", SqlDbType.Decimal) { Precision = 18, Scale = 0, Value = _dues },
                new SqlParameter("@dues_desc", SqlDbType.NVarChar, -1) { Value = hdRetreatDuesDesc.Value.Trim() },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });

            CodeHelper.Redirect("저장하였습니다.", "/staff/retreatdues");
        }
        else if (mode.Equals("U"))
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_retreatdues_update",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) },
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(hdRetreat.Value.Trim()) },
                new SqlParameter("@dues_nm", SqlDbType.NVarChar, 200) { Value = hdRetreatDuesNM.Value.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@dues", SqlDbType.Decimal) { Precision = 18, Scale = 0, Value = _dues },
                new SqlParameter("@dues_desc", SqlDbType.NVarChar, -1) { Value = hdRetreatDuesDesc.Value.Trim() },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });

            CodeHelper.Redirect("수정하였습니다.", "/staff/retreatdues?mode=modify&seq=" + hdSeq.Value.Trim());
        }
        else if (mode.Equals("D"))
        {
            DataSet dsCheck = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_retreatdues_has_members",
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(ddl_retreat.SelectedValue) },
                new SqlParameter("@dues_seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (dsCheck.Tables[0].Rows.Count > 0)
            {
                divSaveAlert.Visible = true;
                lblAlert.Text = "위 회비구분명으로 등록된 사용자가 있으므로 삭제할 수 없습니다. (변경은 가능함)";
                return;
            }
            else
            {
                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_staff_retreatdues_delete",
                    new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

                CodeHelper.Redirect("삭제하였습니다!", "/staff/retreatdues");
            }
            
        }
    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            if (hdSeq.Value.ToString().Trim().Equals(string.Empty))
                SetData("C");
            else
                SetData("U");

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
            SetData("D");
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
            e.Row.Attributes.Add("onclick", "javascript:detailview_dues('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }

    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetList();
    }


}
