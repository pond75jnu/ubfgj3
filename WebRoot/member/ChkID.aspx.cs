using System;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

public partial class member_ChkID : System.Web.UI.Page
{
    private string _id = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            _id = Request.QueryString["id"];

        if (!Page.IsPostBack)
        {
            ChkID();
        }
    }

    private void ChkID()
    {
        DataSet ds = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_member_chk_id_sel",
            new SqlParameter("@UserName", _id.Trim().ToLower()));

        string _result = string.Empty;
        if (ds.Tables[0].Rows.Count > 0)
            _result = "NO";
        else
            _result = "OK";

        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "setResultID", "<script>parent.$('#txtChkResult').val('" + _result + "');parent.chkResult();</script>");
    }
}
