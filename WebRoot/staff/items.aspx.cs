using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

public partial class staff_items : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        hdRetreat.Value = "1"; // cash_item_master.retreat is kept only for legacy schema compatibility.

        if (!Page.IsPostBack)
        {
                        

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
                        Response.Redirect("/staff/items", false);
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

                btnNew.Visible = true;
                // if (ddl_retreat.Items.Count > 0)
                //     btnNew.Visible = true;
                // else
                //     btnNew.Visible = false;

                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                ddl_code_type_write.Enabled = true;
                divGubun.Visible = true;

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

                ddl_code_type_write.Enabled = true;
                divGubun.Visible = false;

                hdSeq.Value = string.Empty;
                lblWriteModeTitle.Text = "신규입력";
                lblCode.Text = "자동 생성됨";

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

                ddl_code_type_write.Enabled = false;
                divGubun.Visible = false;

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

                ddl_code_type_write.Enabled = true;
                divGubun.Visible = true;

                hdSeq.Value = string.Empty;
                break;
        }
    }

    protected void LoadRetreats()
    {
    }

    protected void GetList()
    {
        try
        {
            //SeDefaultCode();
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_cash_item_get_list",
                new SqlParameter("@cash_type", SqlDbType.Int) { Value = ddl_code_type.SelectedValue.Equals("%") ? (object)DBNull.Value : Convert.ToInt32(ddl_code_type.SelectedValue) });

            gvList.DataSource = ds;
            gvList.DataBind();
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('코드값 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SeDefaultCode() {
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_cash_item_get_detail",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (ds.Tables[0].Rows.Count > 0)
            {
                txtCodeNM.Text = ds.Tables[0].Rows[0]["item_nm"].ToString().Trim();
                lblCode.Text = ds.Tables[0].Rows[0]["seq"].ToString().Trim();
                txtItemDesc.Text = ds.Tables[0].Rows[0]["item_desc"].ToString().Trim();
                ddl_code_type_write.SelectedValue = ds.Tables[0].Rows[0]["cash_type"].ToString().Trim();
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SetData(string mode)
    {
        if (mode.Equals("C"))
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_cash_item_insert",
                new SqlParameter("@cash_type", SqlDbType.Int) { Value = Convert.ToInt32(ddl_code_type_write.SelectedValue) },
                new SqlParameter("@item_nm", SqlDbType.NVarChar, 200) { Value = txtCodeNM.Text.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@item_desc", SqlDbType.NVarChar, -1) { Value = txtItemDesc.Text.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });

            CodeHelper.Redirect("저장하였습니다.", _path);

        }
        else if (mode.Equals("U"))
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_cash_item_update",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) },
                new SqlParameter("@cash_type", SqlDbType.Int) { Value = Convert.ToInt32(ddl_code_type_write.SelectedValue.Trim()) },
                new SqlParameter("@item_nm", SqlDbType.NVarChar, 200) { Value = txtCodeNM.Text.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@item_desc", SqlDbType.NVarChar, -1) { Value = txtItemDesc.Text.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });

            CodeHelper.Redirect("수정하였습니다.", _path + "?mode=modify&seq=" + hdSeq.Value.Trim());

        }
        else if (mode.Equals("D"))
        {
            DataSet dsCheck = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_cash_item_has_payments",
                new SqlParameter("@cash_item_seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (dsCheck.Tables[0].Rows.Count > 0)
            {
                divSaveAlert.Visible = true;
                lblAlert.Text = "위 코드명으로 수입 또는 지출항목이 존재하므로 삭제할 수 없습니다. (변경은 가능함)";
                return;
            }
            else
            {
                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_staff_cash_item_delete",
                    new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

                CodeHelper.Redirect("삭제하였습니다!", _path);
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
            e.Row.Attributes.Add("onclick", "javascript:detailview_items('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }

    // protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    // {
    //     GetList();
    // }

    protected void ddl_code_type_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetList();
    }

}
