using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Globalization;

public partial class staff_registatus : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;

    string _retreat_code = string.Empty;
    string _belong_code = string.Empty;
    string _regi_code = string.Empty;

    string _path = HttpContext.Current.Request.Url.AbsolutePath.ToLower();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        #region 쿼리스트링 체크
        if (!string.IsNullOrEmpty(Request.QueryString["ret"]))
        {
            _retreat_code = Request.QueryString["ret"].ToString().Trim();

        }
        if (!string.IsNullOrEmpty(Request.QueryString["belong"]))
        {
            _belong_code = Request.QueryString["belong"].ToString().Trim();

        }
        if (!string.IsNullOrEmpty(Request.QueryString["reg"]))
        {
            _regi_code = Request.QueryString["reg"].ToString().Trim();

        }
        #endregion

        if (!Page.IsPostBack)
        {
            LoadRetreats();
            LoadGroups();
            LoardDuesInfo();

            try
            {
                int i = 0;

                if (int.TryParse(_retreat_code, out i))
                {
                    ddl_retreat.SelectedValue = _retreat_code;
                }

                if (int.TryParse(_belong_code, out i))
                {
                    ddl_group.SelectedValue = _belong_code;
                }

                if (int.TryParse(_regi_code, out i))
                {
                    ddl_regi_type.SelectedValue = _regi_code;
                }
            }
            catch (Exception)
            {

            }

            GetRegistList();

            id_left_menu.mRetreat = ddl_retreat.SelectedValue;
            id_left_menu.mBelong = ddl_group.SelectedValue;

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

    protected void LoadGroups()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_groups_get_active_by_retreat",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue));


            if (ds.Tables[0].Rows.Count > 0) 
            {
                ddl_group.DataSource = ds;
                ddl_group.DataBind();

                ddl_group.Items.Insert(0, new ListItem("== 전체 (요회) ==", "%"));
                
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회 정보가 없습니다. (관리자 문의)');</script>");
                
                return;
            }
            
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void LoardDuesInfo()
    {
        try
        {
            StringBuilder sb_DuesInfo = new StringBuilder();
            DataSet dsDues = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreatdues_get_list",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                new SqlParameter("@SORT_DIRECTION", "DESC"));

            if (dsDues.Tables[0].Rows.Count > 0)
            {
                sb_DuesInfo.Append("<section class='site-dues-panel' aria-label='회비구분'>");
                sb_DuesInfo.Append("<div class='site-dues-panel-title'>회비구분</div>");
                sb_DuesInfo.Append("<ul class='site-chip-list site-dues-list'>");

                for (int i = 0; i < dsDues.Tables[0].Rows.Count; i++)
                {
                    string duesName = Server.HtmlEncode(dsDues.Tables[0].Rows[i]["dues_nm"].ToString());
                    string duesFormat = Server.HtmlEncode(dsDues.Tables[0].Rows[i]["dues_format"].ToString());

                    sb_DuesInfo.Append("<li>");
                    sb_DuesInfo.Append("<span class='site-chip site-dues-chip'>");
                    sb_DuesInfo.Append("<span class='site-dues-name'>" + duesName + "</span>");
                    sb_DuesInfo.Append("<span class='site-dues-price'>" + duesFormat + "</span>");
                    sb_DuesInfo.Append("</span>");
                    sb_DuesInfo.Append("</li>");
                }
                sb_DuesInfo.Append("</ul>");
                sb_DuesInfo.Append("</section>");
                divDuesInfo.InnerHtml = sb_DuesInfo.ToString();
            }
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('회비 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }


    protected void GetRegistList()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_registatus_get_list",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                new SqlParameter("@BELONG", ddl_group.SelectedValue),
                new SqlParameter("@REGI_TYPE", ddl_regi_type.SelectedValue));

            lvItems.DataSource = ds;
            lvItems.DataBind();

            BindRegistFeeSummary(ds.Tables[0]);

            if (ds.Tables[0].Rows.Count > 0)
            {
                int _upt_yn_cnt = 0;
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    if (ds.Tables[0].Rows[i]["manager_confirm"].ToString().Equals("N") && ds.Tables[0].Rows[i]["checkbox_visible"].ToString().Equals("Y"))
                        _upt_yn_cnt++;
                }

                if (_upt_yn_cnt > 0)
                    btnSave.Enabled = true;
                else
                    btnSave.Enabled = false;

                btnExcel.Enabled = true;
            }
            else
            {
                btnExcel.Enabled = false;
                btnSave.Enabled = false;
            }
                


        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('등록현황 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void BindRegistFeeSummary(DataTable table)
    {
        decimal completeTotal = 0;
        decimal partialTotal = 0;
        int completeCount = 0;
        int partialCount = 0;

        foreach (DataRow row in table.Rows)
        {
            decimal userDues = row["user_dues"] == DBNull.Value ? 0 : Convert.ToDecimal(row["user_dues"]);
            string registStatus = row["regi_status_nm"].ToString();

            if (registStatus.Equals("완전등록"))
            {
                completeTotal += userDues;
                completeCount++;
            }
            else if (registStatus.Equals("부분등록"))
            {
                partialTotal += userDues;
                partialCount++;
            }
        }

        decimal total = completeTotal + partialTotal;
        int totalCount = completeCount + partialCount;

        divRegistFeeSummary.InnerHtml =
            "<div class=\"site-regist-summary-main\">"
            + "<span class=\"site-regist-summary-label\">총 등록비: </span>"
            + "<strong class=\"site-regist-summary-amount\">" + FormatWon(total) + "</strong>"
            + "&nbsp;<span class=\"site-regist-summary-count\">" + FormatPeople(totalCount) + "</span>"
            + "</div>"
            + "<div class=\"site-regist-summary-detail\">"
            + "" + BuildRegistSummaryChip("완전등록: ", completeTotal, completeCount, "complete")
            + "<span class=\"site-regist-summary-mobile-break\" aria-hidden=\"true\"></span>"
            + BuildRegistSummaryChip("부분등록: ", partialTotal, partialCount, "partial")
            + "</div>";
    }

    protected string FormatWon(decimal amount)
    {
        return string.Format(CultureInfo.InvariantCulture, "{0:#,##0}원", amount);
    }

    protected string FormatPeople(int count)
    {
        return string.Format(CultureInfo.InvariantCulture, "{0:#,##0}명", count);
    }

    protected string BuildRegistSummaryChip(string label, decimal amount, int count, string modifier)
    {
        return "<span class=\"site-regist-summary-chip is-" + modifier + "\">"
            + "<span class=\"site-regist-summary-chip-label\">" + label + "</span>"
            + "<strong class=\"site-regist-summary-chip-amount\">" + FormatWon(amount) + "</strong>"
            + "&nbsp;<span class=\"site-regist-summary-chip-count\">(" + FormatPeople(count) + ")</span>"
            + "</span>";
    }

    protected void listView_ItemDataBound(object sender, ListViewItemEventArgs e)
    {
        CheckBox _ChkBox;
        Label _Label;
        if (e.Item.ItemType == ListViewItemType.DataItem)
        {
            _ChkBox = (CheckBox)e.Item.FindControl("chkBox1");
            _Label = (Label)e.Item.FindControl("lblNocheck");

            System.Data.DataRowView rowView = e.Item.DataItem as System.Data.DataRowView;

            string _manager_confirm= rowView["manager_confirm"].ToString();
            string _etc_confirm= rowView["etc_confirm"].ToString();

            string _manager_confirm_visible= rowView["checkbox_visible"].ToString();

            if (_manager_confirm.Equals("Y"))
                _ChkBox.Checked = true;
            else
                _ChkBox.Checked = false;

            if (_manager_confirm.Equals("Y") && _etc_confirm.Equals("Y"))
            {
                _ChkBox.Visible = false;
                _Label.Text = "확인함";
            }
            else
            {
                if (_manager_confirm_visible.Equals("Y"))
                {
                    _ChkBox.Visible = true;
                    _Label.Text = string.Empty;
                }   
                else
                {
                    _ChkBox.Visible = false;
                    _Label.Text = "-";
                }
            }
                
        }

    }


    // protected void lvItems_PagePropertiesChanged(object sender, EventArgs e)
    // {
        
    //     // if (txtSearch.Value.Trim().Equals(string.Empty))
    //     // {
    //     //     _search = "N";
    //     //     SearchList();
    //     // }
    //     // else
    //     // {
    //     //     _search = "Y";
    //     //     SearchList();
    //     // }
    // }

    protected void ddl_group_SelectedIndexChanged(object sender, EventArgs e)
    {        
        Response.Redirect("/staff/registatus.aspx?ret=" + ddl_retreat.SelectedValue + "&belong=" + ddl_group.SelectedValue + "&reg=" + ddl_regi_type.SelectedValue, false);
    }

    protected void ddl_regi_type_SelectedIndexChanged(object sender, EventArgs e)
    {
        Response.Redirect("/staff/registatus.aspx?ret=" + ddl_retreat.SelectedValue + "&belong=" + ddl_group.SelectedValue + "&reg=" + ddl_regi_type.SelectedValue, false);
    }

    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        Response.Redirect("/staff/registatus.aspx?ret=" + ddl_retreat.SelectedValue + "&belong=" + ddl_group.SelectedValue + "&reg=" + ddl_regi_type.SelectedValue, false);
    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {

            foreach (ListViewDataItem item in this.lvItems.Items)
            {
                if (item.ItemType == ListViewItemType.DataItem)
                {
                    CheckBox _chkUser = item.FindControl("chkBox1")as CheckBox;
                    string _lblUptYN = (item.FindControl("lblUptYN")as Label).Text;
                    string _seq = (item.FindControl("lblSeq")as Label).Text;
                    string _upt_manager_confirm = _chkUser.Checked ? "Y" : "N";

                    if (_lblUptYN.Equals("Y"))
                    {
                        EfStoredProcedure.ExecuteNonQuery(
                            "ubfgj3.dbo.SP_registatus_confirm_update",
                            new SqlParameter("@SEQ", _seq),
                            new SqlParameter("@MANAGER_CONFIRM", _upt_manager_confirm));
                    }
                }
            }

            CodeHelper.Redirect("실무자확인 처리되었습니다.", "/staff/registatus.aspx?belong=" + ddl_group.SelectedValue);
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('실무자 확인 처리 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

}
