using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

public partial class info_modify02 : System.Web.UI.Page
{
    #region 변수
    public string my_question = string.Empty;    
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        if (!Page.IsPostBack)
        {
            GetUserInfo();
        }
    }

    private void GetUserInfo()
    {
        DataSet _ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_member_password_question_sel",
            new SqlParameter("@LoginId", _login_id.ToLower()));

        if (_ds.Tables[0].Rows.Count > 0)
        {
            my_question = _ds.Tables[0].Rows[0]["PasswordQuestion"].ToString();
        }

    }

    protected void btnChangeQuestionAnswer_Click(object sender, EventArgs e)
    {
        try
        {
            MembershipUser u = Membership.GetUser(User.Identity.Name);
            Boolean result = u.ChangePasswordQuestionAndAnswer(txtMyPassword.Text,
                                        txtNewQuestion.Text.Trim(),
                                        txtAnswer.Text.Trim()
                                );


            if (result)
                CodeHelper.Redirect("본인확인용 질문·답변이 새로 설정되었습니다.", "/");
            else
                CodeHelper.Redirect("본인확인용 질문·답변 설정이 실패하였습니다!!\\n비밀번호가 맞게 입력되었는지 확인 바랍니다!!!", "/info/modify02");
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('본인확인용질문 초기화 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }

    }

}
