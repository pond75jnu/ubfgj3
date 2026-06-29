using System;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

public partial class info_modify01 : System.Web.UI.Page
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
            GetDetail();

            LoadGroups();
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_member_detail_sel",
                new SqlParameter("@LoginId", _login_id.ToLower()));

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

    protected void LoadGroups()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_group_retreat_list_sel",
                new SqlParameter("@Retreat", SqlDbType.Int) { Value = Convert.ToInt32(CodeHelper.RetreatCode) });

            ddl_group.DataSource = ds;
            ddl_group.DataBind();

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('요회목록 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
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
                new SqlParameter("@LoginId", _login_id.ToLower()));

            if (ds.Tables[0].Rows.Count > 0)
            {
                lblEmailAlert.Text = hdEmail.Value.Trim().Replace("\"", "").Replace("'", "") + " 은 다른 사용자가 사용중인 이메일입니다.";
            }
            else
            {
                lblEmailAlert.Text = string.Empty;
                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_member_profile_upd",
                    new SqlParameter("@LoginId", _login_id.ToLower()),
                    new SqlParameter("@KorNm", hdKorNm.Value.Trim().Replace("\"", "").Replace("'", "")),
                    new SqlParameter("@Belong", SqlDbType.Int) { Value = Convert.ToInt32(hdBelong.Value) },
                    new SqlParameter("@Email", email));

                CodeHelper.Redirect("저장하였습니다.", "/info/modify01");
            }



        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('저장 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }

    }

}
