using System;
using System.Web.UI;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //수양회 정보 로딩.....
            GetRetreatInfo();
        }
    }

    protected void GetRetreatInfo()
    {
        try
        {
            string _retreat_seq = string.Empty;
            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_info_sel");

            if (ds.Tables[0].Rows.Count > 0)
            {
                btnProgramView.Visible = !ds.Tables[0].Rows[0]["file_nm"].ToString().Trim().Equals(string.Empty);
                btnProgramView.HRef = CodeHelper.ToCanonicalUrl("/retreat_program_viewer");

                _retreat_seq = ds.Tables[0].Rows[0]["seq"].ToString();
                mTitle.InnerHtml = ds.Tables[0].Rows[0]["retreat_name"].ToString();
                mDesc.InnerHtml = ds.Tables[0].Rows[0]["retreat_desc"].ToString().Replace(" ", "&nbsp;").Replace("\r\n", "<br />");
                
                StringBuilder sb_PlaceTerm = new StringBuilder();
                StringBuilder sb_DuesInfo = new StringBuilder();

                sb_PlaceTerm.Append("<ul>");
                sb_PlaceTerm.Append("<li>");
                sb_PlaceTerm.Append("장소 : " + ds.Tables[0].Rows[0]["retreat_place"].ToString());
                sb_PlaceTerm.Append("</li>");
                sb_PlaceTerm.Append("<li>");
                sb_PlaceTerm.Append("기간 : " + ds.Tables[0].Rows[0]["retreat_term"].ToString());
                sb_PlaceTerm.Append("</li>");
                sb_PlaceTerm.Append("<ul>");
                
                mPlaceTerm.InnerHtml = sb_PlaceTerm.ToString();


                DataSet dsDues = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_retreat_dues_by_retreat_sel",
                    new SqlParameter("@Retreat", _retreat_seq));

                if (dsDues.Tables[0].Rows.Count > 0)
                {
                    sb_DuesInfo.Append("<ul>");
                    for (int i = 0; i < dsDues.Tables[0].Rows.Count; i++)
                    {
                        sb_DuesInfo.Append("<li>");
                        sb_DuesInfo.Append(dsDues.Tables[0].Rows[i]["dues_nm"].ToString() + " : ");
                        sb_DuesInfo.Append(dsDues.Tables[0].Rows[i]["dues_format"].ToString());
                        sb_DuesInfo.Append("</li>");
                    }
                    sb_DuesInfo.Append("</ul>");
                    if (!dsDues.Tables[0].Rows[0]["bank_no"].ToString().Trim().Equals(string.Empty))
                    {
                        sb_DuesInfo.Append("<hr /><span style='padding-left:14px;'>☞ ");
                        sb_DuesInfo.Append("입금계좌 : ");
                        sb_DuesInfo.Append(dsDues.Tables[0].Rows[0]["bank_no"].ToString());
                        sb_DuesInfo.Append("</span>");
                    }
                    mDuesInfo.InnerHtml = sb_DuesInfo.ToString();
                }

                
            }
            
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

}
