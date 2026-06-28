using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Data;
using System.Data.SqlClient;

public partial class usercontrol_top_nav : System.Web.UI.UserControl
{
    string _auth = UserInfo.UserRole.ToLower();    
    string _path = HttpContext.Current.Request.Url.AbsolutePath.ToLower().Replace("default.aspx", "");

    protected void Page_Load(object sender, EventArgs e)
    {
        pnlRetreatSwitch.Visible = CanSwitchRetreat();

        if (!Page.IsPostBack)
        {
            BindRetreatSwitch();
            SetMenu();

            GetAuth();
        }
    }


    protected void SetMenu()
    {
        try
        {
            DataSet ds1 = null;
            DataSet ds2 = null;

            ds1 = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_menu_top_nav_parent_sel",
                new SqlParameter("@Auth", _auth),
                new SqlParameter("@Path", _path));



            StringBuilder sb = new StringBuilder();
            sb.Append("<ul class='site-nav-list'>");

            if (ds1.Tables[0].Rows.Count > 0 && !_path.Equals("/member/login.aspx") && !_path.Equals("/member/join.aspx"))
            {
                for (int i = 0; i < ds1.Tables[0].Rows.Count; i++)
                {
                    if (ds1.Tables[0].Rows[i]["subis"].ToString().Equals("Y"))
                    {
                        sb.Append("<li class='site-nav-item site-nav-dropdown'>");

                        if (ds1.Tables[0].Rows[i]["pathis"].ToString().Equals("Y"))
                            sb.Append("<a class='site-nav-link site-nav-dropdown-toggle is-active' href='" + ds1.Tables[0].Rows[i]["menu_path"].ToString() + @"' ");
                        else
                            sb.Append("<a class='site-nav-link site-nav-dropdown-toggle' href='" + ds1.Tables[0].Rows[i]["menu_path"].ToString() + @"' ");
                        sb.Append("aria-expanded='false' data-site-dropdown-toggle>");
                        sb.Append(ds1.Tables[0].Rows[i]["menu_nm"].ToString());
                        sb.Append("</a>");
                        sb.Append("<ul class='site-nav-dropdown-menu'>");
                        ds2 = EfStoredProcedure.ExecuteDataSet(
                            "ubfgj3.dbo.SP_menu_top_nav_child_sel",
                            new SqlParameter("@Auth", _auth),
                            new SqlParameter("@ParentSeq", ds1.Tables[0].Rows[i]["seq"].ToString()));

                        if (ds2.Tables[0].Rows.Count > 0)
                        {
                            for (int j = 0; j < ds2.Tables[0].Rows.Count; j++)
                            {
                                if (_path.Equals(ds2.Tables[0].Rows[j]["menu_path"].ToString().ToLower().Trim()))
                                    sb.Append("<li><a class='site-nav-dropdown-link is-active'");
                                else
                                    sb.Append("<li><a class='site-nav-dropdown-link'");

                                sb.Append("href='" + ds2.Tables[0].Rows[j]["menu_path"].ToString() + @"'>");
                                sb.Append(ds2.Tables[0].Rows[j]["menu_nm"].ToString());
                                sb.Append("</a></li>");
                            }

                        }
                        sb.Append("</ul>");
                        sb.Append("</li>");
                    }
                    else
                    {
                        sb.Append("<li class='site-nav-item'>");

                        if (_path.Equals(ds1.Tables[0].Rows[i]["menu_path"].ToString().ToLower().Trim()))
                            sb.Append("<a class='site-nav-link is-active' href='/'>수양회정보</a>");
                        else
                            sb.Append("<a class='site-nav-link' href='/'>수양회정보</a>");

                        sb.Append("</li>");
                    }
                }
            }

            sb.Append("</ul>");


            sb.Append("<div class='site-nav-actions'>");

            if(UserInfo.UserID.ToLower().Equals("anonymous") || UserInfo.UserID.ToLower().Equals(""))
            {
                sb.Append("<a href='/member/login.aspx' class='site-nav-action-link'>로그인</a>");
                sb.Append("<a href='/member/join.aspx' class='site-nav-action-link site-nav-action-primary'>회원가입</a>");
            }
            else
            {
                if (CanSwitchRetreat())
                    sb.Append("<button type='button' class='site-nav-action-link site-nav-switch-button' data-retreat-switch-open>수양회 전환</button>");

                sb.Append("<a href='/info/modify01.aspx' class='site-nav-action-link'>" + UserInfo.LoginUserKOR_NM + @"(" + UserInfo.RoleDesc(UserInfo.UserId(UserInfo.UserID)) + @")</a>");
                sb.Append("<a href='/member/logout.aspx' class='site-nav-action-link site-nav-action-primary'>로그아웃</a>");

                SetBelong();
            }

            


            sb.Append("</div>");


            divTopMenu.InnerHtml = sb.ToString();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('메뉴 로딩 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
        


    }

    protected bool CanSwitchRetreat()
    {
        return _auth.Equals("admin") || _auth.Equals("manager");
    }

    protected void BindRetreatSwitch()
    {
        if (!CanSwitchRetreat())
            return;

        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_get_list");
            ddlRetreatSwitch.Items.Clear();

            string currentRetreatName = string.Empty;

            if (ds.Tables.Count > 0)
            {
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    string retreatSeq = row["seq"].ToString().Trim();
                    string retreatName = row["retreat_name"].ToString().Trim();
                    string retreatTerm = row["retreat_term"].ToString().Trim();
                    bool isActive = row["retreat_yn"].ToString().Trim().Equals("Y", StringComparison.OrdinalIgnoreCase);

                    ListItem item = new ListItem((isActive ? "[사용] " : "") + retreatName + " / " + retreatTerm, retreatSeq);
                    ddlRetreatSwitch.Items.Add(item);

                    if (isActive)
                    {
                        currentRetreatName = retreatName;
                        ddlRetreatSwitch.SelectedValue = retreatSeq;
                    }
                }
            }

            lblCurrentRetreat.Text = currentRetreatName.Equals(string.Empty) ? "현재 사용 중인 수양회가 없습니다." : currentRetreatName;
        }
        catch (Exception ex)
        {
            lblRetreatSwitchAlert.Visible = true;
            lblRetreatSwitchAlert.Text = "수양회 목록을 불러오지 못했습니다: " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void btnRetreatSwitchSave_Click(object sender, EventArgs e)
    {
        if (!CanSwitchRetreat())
        {
            Response.Redirect("/", false);
            return;
        }

        int retreatSeq;
        if (!int.TryParse(ddlRetreatSwitch.SelectedValue, out retreatSeq))
        {
            lblRetreatSwitchAlert.Visible = true;
            lblRetreatSwitchAlert.Text = "전환할 수양회를 선택하십시오.";
            return;
        }

        try
        {
            SqlParameter retreatNameParameter = new SqlParameter("@RETREAT_NAME", SqlDbType.NVarChar, 100);
            retreatNameParameter.Value = DBNull.Value;

            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_retreat_set_only_active",
                new SqlParameter("@SEQ", retreatSeq),
                retreatNameParameter,
                new SqlParameter("@UID", UserInfo.UserID),
                new SqlParameter("@UIP", CodeHelper.GetUserIP));

            SetBelong();
            CodeHelper.Redirect("수양회를 전환하였습니다.", Request.RawUrl);
        }
        catch (Exception ex)
        {
            lblRetreatSwitchAlert.Visible = true;
            lblRetreatSwitchAlert.Text = "수양회 전환 중 에러 발생: " + Server.HtmlEncode(ex.Message);
        }
    }


    protected void GetAuth()
    {
        try
        {
            if (!_path.ToLower().Trim().Equals("/"))
            {
                DataSet ds = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_menu_auth_by_path_sel",
                    new SqlParameter("@Path", _path.ToLower()));

                if (ds.Tables[0].Rows.Count > 0)
                {

                    if (!ds.Tables[0].Rows[0]["menu_auth"].ToString().Trim().ToLower().Contains(_auth.ToLower()))
                    {
                        Response.Redirect("/", false);
                    }
                }
            }
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('권한 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SetBelong()
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_member_master_by_login_sel",
            new SqlParameter("@LoginId", UserInfo.UserID.ToLower()));

        string _now_belong_code = string.Empty;        
        string _now_belong_nm = string.Empty;

        string _new_belong_code = string.Empty;
        string _retreat_code = CodeHelper.RetreatCode;

        if (ds.Tables[0].Rows.Count > 0)
        {
            //현재 자신의 회원정보에 입력된 요회코드를 가져온다.
            _now_belong_code = ds.Tables[0].Rows[0]["belong"].ToString().Trim();
            _now_belong_nm = ds.Tables[0].Rows[0]["belong_nm"].ToString().Trim();


            //현재 자신의 회원정보에 입력된 요회코드로 현재의 수양회상태에서 요회정보가 조회되는지 확인
            ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_group_seq_match_sel",
                new SqlParameter("@Seq", _now_belong_code),
                new SqlParameter("@BelongNm", _now_belong_nm),
                new SqlParameter("@Retreat", _retreat_code));

            //요회코드가 존재하지 않을 경우
            if (ds.Tables[0].Rows.Count == 0)
            {
                //요회이름으로 현재의 요회코드를 확인하여 업데이트
                ds = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_group_seq_by_name_sel",
                    new SqlParameter("@BelongNm", _now_belong_nm),
                    new SqlParameter("@Retreat", _retreat_code));

                if (ds.Tables[0].Rows.Count > 0)
                {
                    _new_belong_code = ds.Tables[0].Rows[0]["seq"].ToString().Trim();

                    EfStoredProcedure.ExecuteNonQuery(
                        "ubfgj3.dbo.SP_member_belong_upd",
                        new SqlParameter("@LoginId", UserInfo.UserID.ToLower()),
                        new SqlParameter("@Belong", _new_belong_code));
                }
                
            }
        }

        
    }

}
