using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

public partial class manage_members : System.Web.UI.Page
{
    private const string PasswordResetAllowedLoginId = "pond75";
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = HttpContext.Current.Request.Url.AbsolutePath.ToLower();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        #region 페이지모드 체크
        if (!string.IsNullOrEmpty(Request.QueryString["mode"]))
        {
            
            if (Request.QueryString["mode"].ToLower() == "modify")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["id"]))
                {
                    hdID.Value = Request.QueryString["id"].Trim();
                    PageMode("MODIFY");
                }
                else
                    Response.Redirect("/manage/members.aspx", false);
            }
            else
                PageMode("LIST");
        }
        else
            PageMode("LIST");
        #endregion

        if (!Page.IsPostBack)
        {
            
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
                                
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdID.Value = string.Empty;
                break;           
            case "MODIFY":
                divList.Visible = false;
                divWriteModify.Visible = true;

                GetDetail();
                LoadGroups();

                btnList.Visible = true;
                btnSave.Visible = true;

                if (hdID.Value.ToLower().Equals("admin"))
                {
                    if (UserInfo.UserID.ToLower().Equals("admin"))
                    {
                        btnSave.Visible = true;
                        ddl_status.Enabled = false;
                        ddl_type.Enabled = false;
                    }
                    else
                    {
                        btnSave.Visible = false;
                        ddl_status.Enabled = true;
                        ddl_type.Enabled = true;
                    }

                    btnDel.Visible = false;                    
                }
                else
                {
                    btnDel.Visible = true;
                    btnSave.Visible = true;
                }

                if (CanResetPassword())
                    trInitPWD.Visible = true;
                else
                    trInitPWD.Visible = false;

                break;
            default:
                divList.Visible = true;
                divWriteModify.Visible = false;

                GetList();
                                
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdID.Value = string.Empty;
                break;
        }
    }

    protected void LoadGroups()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_group_all_list_sel");

            ddl_group.DataSource = ds;
            ddl_group.DataBind();

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetList()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_manage_member_list_sel",
                new SqlParameter("@SearchName", txtSearchName.Text.Trim().Replace("\"","").Replace("'","")));

            gvList.DataSource = ds;
            gvList.DataBind();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('사용자 목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_member_detail_sel",
                new SqlParameter("@LoginId", hdID.Value.Trim().ToLower()));

            if (ds.Tables[0].Rows.Count > 0)
            {
                txtID.Text = ds.Tables[0].Rows[0]["login_id"].ToString().Trim();
                txtKorNm.Text = ds.Tables[0].Rows[0]["kor_nm"].ToString().Trim();
                txtEmail.Text = ds.Tables[0].Rows[0]["email"].ToString().Trim();

                ddl_group.SelectedValue = ds.Tables[0].Rows[0]["belong_code"].ToString().Trim();
                ddl_type.SelectedValue = ds.Tables[0].Rows[0]["user_type"].ToString().Trim();
                ddl_status.SelectedValue = ds.Tables[0].Rows[0]["IsApproved_code"].ToString().Trim();
            }
            else
                Response.Redirect("/", false);

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('상세 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SendEmail()
    {
        try
        {
            string strReceiveMail = string.Empty; //받는사람 이메일
            string strTitle = string.Empty; //메일 제목
            string strContent = string.Empty; //메일 내용

            strReceiveMail = Membership.GetUser(hdID.Value.Trim()).Email;

            strTitle = "(ubfgj3.kr) 회원 정보 수정 알림";

            strContent = "관리자에 의해 회원님의 정보가 아래와 같이 저장(수정)되어 알려드립니다.<br /><br />"
                    + "- (아이디) " + hdID.Value.Trim() + @"<br />"
                    + "- (성 명) " + hdKorNm.Value + @"<br />"
                    + "- (이메일) " + hdEmail.Value + @"<br />"
                    + "- (역 할) " + hdUserTypeNm.Value + @"<br />"
                    + "- (계정상태) " + hdStatusNm.Value + @"<br /><br />"
                    + "수정된 정보에 문제가 있을 시에는 관리자에게 문의하시기 바랍니다.<br /><br /><br />";


            //메일발송
            CodeHelper.SendMail("UBF 광주3부", strTitle, strReceiveMail, strContent, false);
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('저장 후 이메일 발송 중 에러발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }



    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string email = hdEmail.Value.Trim().Replace("\"", "").Replace("'", "");

            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_member_email_duplicate_sel",
                new SqlParameter("@Email", email),
                new SqlParameter("@LoginId", hdID.Value.Trim().ToLower()));

            if (ds.Tables[0].Rows.Count > 0)
            {
                lblEmailAlert.Text = hdEmail.Value.Trim().Replace("\"", "").Replace("'", "") + " 은 다른 사용자가 사용중인 이메일입니다.";
            }
            else
            {
                lblEmailAlert.Text = string.Empty;
                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_manage_member_upd",
                    new SqlParameter("@LoginId", hdID.Value.Trim().ToLower()),
                    new SqlParameter("@KorNm", hdKorNm.Value.Trim().Replace("\"", "").Replace("'", "")),
                    new SqlParameter("@Belong", SqlDbType.Int) { Value = Convert.ToInt32(hdBelong.Value) },
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Status", hdStatus.Value),
                    new SqlParameter("@RoleName", hdUserType.Value));

                if(!hdID.Value.ToLower().Equals("admin"))
                {
                    SendEmail();
                }

                CodeHelper.Redirect("저장하였습니다.", "/manage/members.aspx?mode=modify&id=" + hdID.Value.ToString().Trim());
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
                "ubfgj3.dbo.SP_manage_member_del",
                new SqlParameter("@LoginId", hdID.Value.ToString().Trim().ToLower()));

            CodeHelper.Redirect("삭제하였습니다!", "/manage/members.aspx");
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
            e.Row.Attributes.Add("onclick", "javascript:detailview_member('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {
        GetList();
    }

    protected void btnPasswordInitSet_Click(object sender, EventArgs e)
    {
        SetPassInit();
    }

    private bool CanResetPassword()
    {
        return string.Equals(UserInfo.UserID, PasswordResetAllowedLoginId, StringComparison.OrdinalIgnoreCase);
    }

    protected void SetPassInit()
    {
        if (!CanResetPassword())
        {
            CodeHelper.Redirect("비밀번호 초기화 권한이 없습니다.", "/manage/members.aspx?mode=modify&id=" + hdID.Value.ToString().Trim());
            return;
        }

        if (string.IsNullOrWhiteSpace(txtNewPWD.Text) || string.IsNullOrWhiteSpace(txtNewPWD2.Text))
        {
            CodeHelper.Redirect("변경(초기화) 할 비밀번호를 입력하세요.", "/manage/members.aspx?mode=modify&id=" + hdID.Value.ToString().Trim());
            return;
        }

        if (!txtNewPWD.Text.Trim().Equals(txtNewPWD2.Text.Trim()))
        {
            CodeHelper.Redirect("변경할 비밀번호가 서로 다릅니다.", "/manage/members.aspx?mode=modify&id=" + hdID.Value.ToString().Trim());
            return;
        }

        string connStr = AppConfiguration.GetConnectionString("RetreatConnectionString");

        string salt = GenerateSalt();
        string password = EncryptToHashString(txtNewPWD.Text.Trim(), salt, "SHA1");

        SqlConnection conn = new SqlConnection(connStr);
        conn.Open();

        SqlCommand cmd = new SqlCommand("aspnet_Membership_SetPassword", conn);
        cmd.CommandType = CommandType.StoredProcedure;

        //=== 현재 사용 Membership 공급자 응용 프로그램 웹 이름 ===    
        cmd.Parameters.Add(new SqlParameter("@ApplicationName", Membership.ApplicationName));

        //=== 사용자 계정 
        cmd.Parameters.Add(new SqlParameter("@UserName", hdID.Value));

        //=== 암호화 비밀번호 ===    
        cmd.Parameters.Add(new SqlParameter("@NewPassword", password));

        //=== 비밀번호 암호화 키
        cmd.Parameters.Add(new SqlParameter("@PasswordSalt", salt));

        //=== 암호 초기화 시간 ===    
        cmd.Parameters.Add(new SqlParameter("@CurrentTimeUtc", DateTime.Now));

        //=== 비밀번호 암호화된 형식 (이때 것은 Hash1 주의 전래 매개 변수, int 형태. ) ===    
        cmd.Parameters.Add(new SqlParameter("@PasswordFormat", Membership.Provider.PasswordFormat.GetHashCode()));


        SqlParameter returnValue = new SqlParameter();
        returnValue.ParameterName = "returnValue";
        returnValue.Direction = ParameterDirection.ReturnValue;
        cmd.Parameters.Add(returnValue);

        //=== 실행 저장 프로시저 ===    
        cmd.ExecuteNonQuery();

        conn.Close();




        string msg = string.Empty;

        if (returnValue.Value.ToString() == "0") //=== 검사 암호 초기화 성공 여부 ===  
        {
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_manage_member_password_unlock_upd",
                new SqlParameter("@LoginId", hdID.Value.Trim().ToLower()));
            msg = "\"" + txtKorNm.Text.Trim() + "\" 님의 패스워드가 초기화(변경) 되었습니다.";
        }

        else
            msg = "\"" + txtKorNm.Text.Trim() + "\" 님의 패스워드 초기화(변경)가 실패하였습니다.";

        
        CodeHelper.Redirect(msg, "/manage/members.aspx?mode=modify&id=" + hdID.Value.ToString().Trim());
    }


    #region 패스워드 초기화(변경) 관련 함수 모음
    /// <summary>    
    /// 키 암호    
    /// </summary>    
    /// <returns></returns>    
    public string GenerateSalt()
    {
        byte[] data = new byte[0x10];
        new System.Security.Cryptography.RNGCryptoServiceProvider().GetBytes(data);
        return Convert.ToBase64String(data);
    }

    /// <summary>    
    /// 해시 비밀번호 암호화 (환원할)    
    /// </summary>    
    /// <param name="s">원시 문자열</param>    
    /// <param name="saltKey">Salt암호화 문자열</param>    
    /// <param name="hashName">암호화 형식(MD5, SHA1, SHA256, SHA384, SHA512.)</param>    
    /// <returns>암호화 적이 비밀번호</returns>    
    public string EncryptToHashString(string s, string saltKey, string hashName)
    {
        byte[] src = System.Text.Encoding.Unicode.GetBytes(s);
        byte[] saltbuf = Convert.FromBase64String(saltKey);
        byte[] dst = new byte[saltbuf.Length + src.Length];
        byte[] inArray = null;
        System.Buffer.BlockCopy(saltbuf, 0, dst, 0, saltbuf.Length);
        System.Buffer.BlockCopy(src, 0, dst, saltbuf.Length, src.Length);

        System.Security.Cryptography.HashAlgorithm algorithm = System.Security.Cryptography.HashAlgorithm.Create(hashName);
        inArray = algorithm.ComputeHash(dst);

        return Convert.ToBase64String(inArray);
    }
    #endregion


}
