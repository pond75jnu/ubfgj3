using System;
using System.Data;
using System.Data.SqlClient;

public partial class member_findid : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
        

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string korNm = txtNAME.Text.Trim().Replace("\"", "").Replace("'", "");
        string email = txtEMAIL.Text.ToLower().Trim().Replace("\"", "").Replace("'", "");

        DataSet _ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_member_find_id_sel",
            new SqlParameter("@KorNm", korNm),
            new SqlParameter("@Email", email));

        if (_ds.Tables[0].Rows.Count > 0)
        {
            int _len = _ds.Tables[0].Rows[0]["login_id"].ToString().Length;

            if (_len >= 7)
                lblResult.Text = "아이디 : " + _ds.Tables[0].Rows[0]["login_id"].ToString().Substring(0, 5).PadRight(_len, '*');
            else if (_len < 7 && _len >=5 )
                lblResult.Text = "아이디 : " + _ds.Tables[0].Rows[0]["login_id"].ToString().Substring(0, 3).PadRight(_len,'*');
            else if (_len < 5 && _len >= 3)
                lblResult.Text = "아이디 : " + _ds.Tables[0].Rows[0]["login_id"].ToString().Substring(0, 2).PadRight(_len, '*');
            else
                lblResult.Text = "아이디 : " + _ds.Tables[0].Rows[0]["login_id"].ToString().Substring(0, 1).PadRight(_len, '*');
        }
        else
        {
            lblResult.Text = "입력하신 정보로 아이디를 찾을 수 없습니다.";
        }
    }
}
