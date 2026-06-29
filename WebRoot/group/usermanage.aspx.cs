using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class group_usermanage : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _retreat_code = string.Empty;
    string _belong_code = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();


    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        hdUserRole.Value = _auth.ToLower();

        #region 쿼리스트링 체크
        if (!string.IsNullOrEmpty(Request.QueryString["ret"]))
        {
            _retreat_code = Request.QueryString["ret"].ToString().Trim();

        }

        if (!string.IsNullOrEmpty(Request.QueryString["belong"]))
        {
            _belong_code = Request.QueryString["belong"].ToString().Trim();

        }
        #endregion

        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);
        

        if (!Page.IsPostBack)
        {
            LoadRetreats();
            LoadGroups();
            LoardDuesType();
            LoardDuesInfo();

            
        }

        GetLoadMembers();
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

                ddl_retreat.Enabled = false;
                btnSave.Enabled = true;
            }
            else 
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보가 없습니다. (관리자 문의)');</script>");
                btnSave.Enabled = false;
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

                if (_auth.ToLower().Equals("user"))
                {
                    ddl_group.SelectedValue = UserInfo.LoginUserBelongCode;
                    ddl_group.Enabled = false;
                }
                else if (_auth.ToLower().Equals("manager") || _auth.ToLower().Equals("admin"))
                {
                    ddl_group.Enabled = true;
                }
                else
                    ddl_group.Enabled = false;
                
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회 정보가 없습니다. (관리자 문의)');</script>");
                btnSave.Enabled = false;
                return;
            }
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void LoardDuesType()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreatdues_get_list",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                new SqlParameter("@SORT_DIRECTION", "ASC"));


            if (ds.Tables[0].Rows.Count > 0) 
            {
                hdDuestypesCount.Value = ds.Tables[0].Rows.Count.ToString();

                string _duestypes = string.Empty;
                int _duestypes_string_length = 0;

                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    _duestypes = _duestypes + ds.Tables[0].Rows[i]["seq"].ToString().Trim() + "‡";
                    _duestypes = _duestypes + ds.Tables[0].Rows[i]["dues_nm"].ToString().Trim() + "‡";
                    _duestypes = _duestypes + ds.Tables[0].Rows[i]["dues"].ToString().Trim() + "†";
                }

                _duestypes_string_length = _duestypes.Length;
                hdDuestypes.Value = _duestypes.Substring(0, _duestypes_string_length - 1);

                
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('회비구분 정보가 없습니다. (관리자 문의)');</script>");
                btnSave.Enabled = false;
                return;
            }
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('회비구분 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
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
                new SqlParameter("@SORT_DIRECTION", "ASC"));

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

    protected void GetGroupMembers()
    {
        
        try
        {
            id_left_menu.mRetreat = ddl_retreat.SelectedValue;
            id_left_menu.mBelong = ddl_group.SelectedValue;
            //id_left_menu.GetR

            

            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_group_members_get_for_usermanage",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                new SqlParameter("@BELONG", ddl_group.SelectedValue));

            hdGroupMembersCount.Value = ds.Tables[0].Rows.Count.ToString();

            string _members = string.Empty;
            int _members_string_length = 0;

            if (ds.Tables[0].Rows.Count > 0)
            {
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    _members = _members + ds.Tables[0].Rows[i]["user_nm"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["belong"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["usertype"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["duestype"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["user_dues_format_comma"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["howto_regist"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["user_desc"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["manager_confirm"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["seq"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["regi_status"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["attend"].ToString().Trim() + "‡";
                    _members = _members + ds.Tables[0].Rows[i]["manager_confirm_first"].ToString().Trim() + "†";
                }

                _members_string_length = _members.Length;
                hdGroupMembers.Value = _members.Substring(0, _members_string_length - 1);

            }


        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회멤버 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetLoadMembers()
    {
        //GetMigPossible();

        //try
        //{
        //    int i = 0;
        //    if (int.TryParse(_retreat_code, out i))
        //    {
        //        ddl_retreat.SelectedValue = _retreat_code;
        //    }

        //    if (int.TryParse(_belong_code, out i))
        //    {
        //        ddl_group.SelectedValue = _belong_code;
        //    }


        //}
        //catch (Exception)
        //{

        //}

        try
        {
            ddl_retreat.SelectedValue = _retreat_code;
            ddl_group.SelectedValue = _belong_code;
            hdBeforeGroupNm.Value = ddl_group.SelectedItem.Text.Replace(" 요회", "");

            GetMigPossible();


            GetGroupMembers();
            id_left_menu.mRetreat = ddl_retreat.SelectedValue;
            id_left_menu.mBelong = ddl_group.SelectedValue;
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('멤버 로드 중 에러발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
        
    }

    /// <summary>
    /// 전년도 이관 가능상태 확인
    /// </summary>
    protected void GetMigPossible()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreat_get_previous",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue));

            if (ds.Tables[0].Rows.Count > 0 && !ds.Tables[0].Rows[0]["before_retreat"].ToString().Equals("-1")) //이전 수양회가 존재하고
            {
                //이전수양회 코드 저장
                hdBeforeRetreat.Value = ds.Tables[0].Rows[0]["before_retreat"].ToString();

                ds = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_group_get_previous_by_name",
                    new SqlParameter("@RETREAT", hdBeforeRetreat.Value),
                    new SqlParameter("@BELONG_NM", hdBeforeGroupNm.Value));

                if (ds.Tables[0].Rows.Count > 0 && !ds.Tables[0].Rows[0]["before_belong"].ToString().Equals("-1")) //현재요회명으로 이전 요회가 존재하고
                {

                    hdBeforeGroup.Value = ds.Tables[0].Rows[0]["before_belong"].ToString();

                    ds = EfStoredProcedure.ExecuteDataSet(
                        "ubfgj3.dbo.SP_group_members_get_by_retreat_belong",
                        new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                        new SqlParameter("@BELONG", ddl_group.SelectedValue));

                    if (ds.Tables[0].Rows.Count <= 0) //현재 수양회로 멤버가 존재하지 않고
                    {
                        ds = EfStoredProcedure.ExecuteDataSet(
                            "ubfgj3.dbo.SP_retreatdues_get_list",
                            new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                            new SqlParameter("@SORT_DIRECTION", "ASC"));

                        if (ds.Tables[0].Rows.Count > 0) //현재 수양회로 수양회금액이 존재할 경우에만 이전 사용자정보 이관 가능
                            btnMig.Visible = true;
                        else
                            btnMig.Visible = false;
                    }
                    else
                        btnMig.Visible = false;
                }
                else
                    btnMig.Visible = false;


            }
            else
                btnMig.Visible = false;

            //Response.Write(ddl_group.SelectedItem.Text.Replace(" 요회", "") + " / " + hdBeforeGroup.Value);
        }
        catch (Exception ex)
        {
            //Response.Write(ex);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('구성원 이전가능여부 체크 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }


    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            if (!hdSaveMembers.Value.Trim().Equals(string.Empty))
            {                

                string _save_data = hdSaveMembers.Value.Trim();
                string[] _save_data_types = _save_data.Split('†');

                string _save_data_type_01 = _save_data_types[0].Replace("‡행삭제‡", "#");
                string _save_data_type_02 = _save_data_types[1];
                string _save_data_type_03 = _save_data_types[2];
                string _save_data_type_04 = _save_data_types[3];
                string _save_data_type_05 = _save_data_types[4];

                string _save_data_type_01_real = _save_data_type_01.Substring(0, _save_data_type_01.Length - 1);
                string _save_data_type_02_real = _save_data_type_02.Substring(0, _save_data_type_02.Length - 1);
                string _save_data_type_03_real = _save_data_type_03.Substring(0, _save_data_type_03.Length - 1);
                string _save_data_type_04_real = _save_data_type_04.Substring(0, _save_data_type_04.Length - 1);
                string _save_data_type_05_real = _save_data_type_05.Substring(0, _save_data_type_05.Length - 1);

                string[] _save_row = _save_data_type_01_real.Split('#');
                string[] _save_col = null;

                string[] _save_usertype = _save_data_type_02_real.Split('‡');
                string[] _save_duestype = _save_data_type_03_real.Split('‡');
                string[] _save_howtoregist = _save_data_type_04_real.Split('‡');
                string[] _save_attend = _save_data_type_05_real.Split('‡');

                string _save_nm = string.Empty;
                int _save_dues = 0;
                string _save_desc = string.Empty;
                string _save_seq = string.Empty;
                string _save_usertype_value = string.Empty;
                string _save_duestype_value = string.Empty;
                string _save_howtoregist_value = string.Empty;
                string _save_attend_value = string.Empty;

                string _manage_confirm = _auth.ToLower().Equals("admin") || _auth.ToLower().Equals("manager") ? "Y" : "N";

                DataSet ds_Sav = null;

                StringBuilder keepSeqList = new StringBuilder();
                
                int _chk = 0;          

                for (int i = 0; i < _save_row.Length; i++)
                {
                    _save_col = _save_row[i].Split('‡');

                    _save_nm = _save_col[0].Trim().Replace("\"", "").Replace("'", "");
                    _save_dues = CodeHelper.ParseWholeWonInt(_save_col[1], "납부금액");
                    _save_desc = _save_col[2].Trim().Replace("\"", "").Replace("'", "");
                    _save_seq = _save_col[3].Trim();
                    _save_usertype_value = _save_usertype[i].Trim();
                    _save_duestype_value = _save_duestype[i].Trim();
                    _save_howtoregist_value = _save_howtoregist[i].Trim();
                    _save_attend_value = _save_attend[i].Trim();

                    _manage_confirm = (_auth.ToLower().Equals("admin") || _auth.ToLower().Equals("manager")) && _save_dues > 0 ? "Y" : "N";

                    //이름이 비어있지 않거나, 저정된 키값(seq)가 없을 경우에는 새 행으로 처리함
                    if (!_save_nm.Equals(string.Empty) && _save_seq.Trim().Equals(string.Empty))
                    {
                        //새로 추가한다.
                        ds_Sav = EfStoredProcedure.ExecuteDataSet(
                            "ubfgj3.dbo.SP_group_member_save",
                            new SqlParameter("@SEQ", DBNull.Value),
                            new SqlParameter("@USER_NM", _save_nm),
                            new SqlParameter("@BELONG", ddl_group.SelectedValue),
                            new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                            new SqlParameter("@USERTYPE", _save_usertype_value),
                            new SqlParameter("@DUESTYPE", _save_duestype_value),
                            new SqlParameter("@USER_DUES", _save_dues),
                            new SqlParameter("@HOWTO_REGIST", _save_howtoregist_value),
                            new SqlParameter("@USER_DESC", _save_desc),
                            new SqlParameter("@MANAGER_CONFIRM", _manage_confirm),
                            new SqlParameter("@ATTEND", _save_attend_value),
                            new SqlParameter("@UID", _login_id),
                            new SqlParameter("@UIP", CodeHelper.GetUserIP),
                            new SqlParameter("@AUTH", _auth.ToLower()));

                        if (keepSeqList.Length > 0)
                            keepSeqList.Append(",");
                        keepSeqList.Append(ds_Sav.Tables[0].Rows[0]["new_seq"].ToString());
                        _chk = _chk + 1;
                    }
                    //이름이 비어있지 않거나, 저정된 키값(seq)가 있는 경우에는 기존 행으로 처리함
                    else if (!_save_nm.Equals(string.Empty) && !_save_seq.Trim().Equals(string.Empty))
                    {
                        // 업데이트 한다.
                        ds_Sav = EfStoredProcedure.ExecuteDataSet(
                            "ubfgj3.dbo.SP_group_member_save",
                            new SqlParameter("@SEQ", _save_seq),
                            new SqlParameter("@USER_NM", _save_nm),
                            new SqlParameter("@BELONG", ddl_group.SelectedValue),
                            new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                            new SqlParameter("@USERTYPE", _save_usertype_value),
                            new SqlParameter("@DUESTYPE", _save_duestype_value),
                            new SqlParameter("@USER_DUES", _save_dues),
                            new SqlParameter("@HOWTO_REGIST", _save_howtoregist_value),
                            new SqlParameter("@USER_DESC", _save_desc),
                            new SqlParameter("@MANAGER_CONFIRM", _manage_confirm),
                            new SqlParameter("@ATTEND", _save_attend_value),
                            new SqlParameter("@UID", _login_id),
                            new SqlParameter("@UIP", CodeHelper.GetUserIP),
                            new SqlParameter("@AUTH", _auth.ToLower()));

                        if (keepSeqList.Length > 0)
                            keepSeqList.Append(",");
                        keepSeqList.Append(_save_seq);
                        _chk = _chk + 1;

                    }
                    //이름이 비어있으면서, 저정된 키값(seq)가 있는 경우 삭제되는 것을 막기 위해 해당 seq를
                    //삭제를 위한 WHERE 조건에 추가
                    else if (_save_nm.Equals(string.Empty) && !_save_seq.Trim().Equals(string.Empty))
                    {
                        if (keepSeqList.Length > 0)
                            keepSeqList.Append(",");
                        keepSeqList.Append(_save_seq);
                        _chk = _chk + 1;
                    }
                }


                if (_chk != 0) //_chk 가 0인 경우는 추가한 사람이 한명도 없거나 추가행이 이름을 하나도 넣지 않은 경우
                {
                    // 필요없는 자료들 삭제한다.
                    EfStoredProcedure.ExecuteNonQuery(
                        "ubfgj3.dbo.SP_group_members_delete_missing",
                        new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                        new SqlParameter("@BELONG", ddl_group.SelectedValue),
                        new SqlParameter("@KEEP_SEQ_LIST", keepSeqList.ToString()));
                }

            }
            else 
            {
                // 관리자나 실무자가 아닌 경우에는 실무자가 확인한것 제외하고 전체를 지운다.
                // 관리자나 실무자인 경우는 실무자가 확인했을지라도 지울 수 있다.
                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_group_members_delete_by_group",
                    new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                    new SqlParameter("@BELONG", ddl_group.SelectedValue),
                    new SqlParameter("@DELETE_CONFIRMED", _auth.ToLower().Equals("admin") || _auth.ToLower().Equals("manager") ? "Y" : "N"));
            }

            CodeHelper.Redirect("저장하였습니다.", "/group/usermanage?belong=" + ddl_group.SelectedValue);

            //GetLoadMembers();
            //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('저장하였습니다!');</script>");
        }
        catch (Exception ex)
        {
            //Response.Write(ex);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('구성원 정보 저장 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void ddl_group_SelectedIndexChanged(object sender, EventArgs e)
    {
        
        //GetLoadMembers();

        //left메뉴 요회별등록현황을 가져오기 위해 아래와 같이 처리
        Response.Redirect("/group/usermanage?belong=" + ddl_group.SelectedValue, false);
    }

    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetGroupMembers();
    }

    protected void btnMig_Click(object sender, EventArgs e)
    {
        try
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_group_members_migrate",
                new SqlParameter("@RETREAT", ddl_retreat.SelectedValue),
                new SqlParameter("@BELONG", ddl_group.SelectedValue),
                new SqlParameter("@BEFORE_RETREAT", hdBeforeRetreat.Value),
                new SqlParameter("@BEFORE_BELONG", hdBeforeGroup.Value),
                new SqlParameter("@UID", _login_id),
                new SqlParameter("@UIP", CodeHelper.GetUserIP));

            //GetLoadMembers();
            //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('이전 수양회 구성원을 이관하였습니다.');</script>");
            CodeHelper.Redirect("이전 수양회 구성원을 이관하였습니다.", "/group/usermanage?belong=" + ddl_group.SelectedValue);
        }
        catch (Exception ex)
        {
            //Response.Write(ex);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('이전 수양회 구성원 이관 도중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    

}
