using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Web.Security;

public partial class member_join : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // 요회목록 가져오기
            LoadGroups();

            //로그인 된 경우에는 메인화면으로 이동
            GetLoginStatus();

            //이용약관, 개인정보수집동의 절차 생략.. 차후에 작업예정..
            hdJoinMode.Value = "COMPLETE_STEP01";
            //Session["STATE"] = null;
            CheckJoinMode();
        }
    }

    /// <summary>
    /// 로그인 상태 파악
    /// </summary>
    private void GetLoginStatus()
    {
        string userID = string.Empty;

        try
        {
            userID = Membership.GetUser().UserName;
            //위 코드가 에러 없이 실행 되는 것은 로그인 된 상태를 의미함

            //로그인 된 경우에는 메인 화면으로 이동
            Response.Redirect("/", false);

        }
        catch (Exception)
        {
            //에러난 경우는 로그인 안된것으로 간주 그대로 유지
        }
    }

    /// <summary>
    /// 페이지 Session 상태에 따라 화면 설정
    /// </summary>
    private void CheckJoinMode()
    {
        if (!hdJoinMode.Value.ToString().Trim().Equals(string.Empty))
        {
            switch (hdJoinMode.Value.ToString().Trim())
            {
                case "COMPLETE_STEP01":
                    divJoinStep01.Visible = true;
                    divJoinStep02.Visible = false;
                    break;
                case "COMPLETE_STEP02":
                    divJoinStep01.Visible = false;
                    divJoinStep02.Visible = true;
                    break;
                default:
                    divJoinStep01.Visible = false;
                    divJoinStep02.Visible = false;
                    break;
            }
        }
        else
        {
            divJoinStep01.Visible = false;
            divJoinStep02.Visible = false;
        }

    }

    protected void LoadGroups()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_member_join_group_list_sel",
                new SqlParameter("@Retreat", SqlDbType.Int) { Value = Convert.ToInt32(CodeHelper.RetreatCode) });

            ddl_group.DataSource = ds;
            ddl_group.DataBind();

            ddl_group.Items.Insert(0, new ListItem("== 요회선택 ==", "-1"));


        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    private void SaveMember()
    {
        #region 이메일 중복체크
        DataSet _ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_member_join_email_check_sel",
            new SqlParameter("@Email", txtJoinEMAIL.Text.ToLower().Trim()));
        #endregion

        if (_ds.Tables[0].Rows.Count > 0)
        {
            CheckJoinMode();
            hdJoinMode.Value = "COMPLETE_STEP01";

            divEmailAlert.Visible = true;            
            txtJoinEMAIL.Text = string.Empty;
            txtJoinEMAIL.Focus();
        }
        else
        {
            divEmailAlert.Visible = false;

            MembershipCreateStatus result;

            //사용자 멤버쉽 추가
            MembershipUser newUser = Membership.CreateUser(
                        txtJoinID.Text,
                        txtJoinPWD.Text,
                        txtJoinEMAIL.Text,
                        txtConfirm01.Text.Trim(), //패스워드 분실 시 확인용 질문
                        txtConfirm02.Text.Trim(), //패스워드 분실 시 확인용 답변
                        false, //계정 잠금상태
                        out result
                    );

            //권한 추가
            Roles.AddUserToRole(txtJoinID.Text, ddl_type.SelectedValue.ToString());

            //사용자 마스터 추가
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_member_master_ins",
                new SqlParameter("@LoginId", txtJoinID.Text),
                new SqlParameter("@KorNm", txtJoinNM.Text),
                new SqlParameter("@Belong", SqlDbType.Int) { Value = Convert.ToInt32(hdBelongCode.Value) },
                new SqlParameter("@BelongNm", hdBelongName.Value),
                new SqlParameter("@Email", txtJoinEMAIL.Text.Trim()),
                new SqlParameter("@UserIp", CodeHelper.GetUserIP));


            #region 이메일 발송
            string strReceiveMail = string.Empty; //받는사람 이메일
            string strTitle = string.Empty; //메일 제목
            string strContent = string.Empty; //메일 내용



            strReceiveMail = Membership.GetUser("admin").Email;

            strTitle = "ubfgj3.kr 사이트 신규 회원 가입 알림";

            strContent = "ubfgj3.kr 사이트에 신규 사용자가 회원가입 하였습니다.<br /><br />"
                    + "- 아이디 : " + txtJoinID.Text + @"<br />"
                    + "- 성명 : " + txtJoinNM.Text + @"<br />"
                    + "- 요회 : " + hdBelongName.Value + @"<br /><br />"
                    + "사이트에 방문하여 사용자 정보 확인 후 승인처리 해주시기 바랍니다.<br /><br /><br />";

            
            //메일발송
            CodeHelper.SendMail("[ubf광주3부]", strTitle, strReceiveMail, strContent, false);
            #endregion

            hdJoinMode.Value = "COMPLETE_STEP02";
            CheckJoinMode();
        }
    }

    protected void btnIdChk_Click(object sender, EventArgs e)
    {
        ifrChkID.Src = "ChkID.aspx?id=" + txtJoinID.Text.Trim();
    }

    protected void btnStep02_Click(object sender, EventArgs e)
    {
        try
        {
            SaveMember();
            
        }
        catch (Exception err)
        {
            lblCreateUsereErr.Text = err.Message;
        }

    }

    protected void btnStepCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("/member/join.aspx", false);
    }

    protected void btnStep03_Click(object sender, EventArgs e)
    {
        Response.Redirect("/", false);
    }
}
