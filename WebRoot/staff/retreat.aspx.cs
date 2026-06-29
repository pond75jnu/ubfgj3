using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.IO;

public partial class staff_retreat : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);

        #region 페이지모드 체크
        if (!string.IsNullOrEmpty(Request.QueryString["mode"]))
        {


            if (Request.QueryString["mode"].ToLower() == "write")
            {
                PageMode("WRITE");
            }
            else if (Request.QueryString["mode"].ToLower() == "modify")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["seq"]))
                {
                    hdSeq.Value = Request.QueryString["seq"].Trim();
                    PageMode("MODIFY");
                }
                else
                    Response.Redirect("/staff/retreat", false);
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

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                break;
            case "WRITE":
                divList.Visible = false;
                divWriteModify.Visible = true;

                btnNew.Visible = false;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                lblWriteModeTitle.Text = "신규입력";
                break;
            case "MODIFY":
                divList.Visible = false;
                divWriteModify.Visible = true;

                GetDetail();

                btnNew.Visible = false;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = true;

                lblWriteModeTitle.Text = "수정";
                break;
            default:
                divList.Visible = true;
                divWriteModify.Visible = false;

                GetList();

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;

                hdSeq.Value = string.Empty;
                break;
        }
    }

    protected void GetList()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_get_list");

            gvList.DataSource = ds;
            gvList.DataBind();
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreat_get_detail",
                new SqlParameter("@SEQ", hdSeq.Value.ToString().Trim()));

            if (ds.Tables[0].Rows.Count > 0)
            {
                txtRetreatName.Text = ds.Tables[0].Rows[0]["retreat_name"].ToString().Trim();
                txtRetreatPlace.Text = ds.Tables[0].Rows[0]["retreat_place"].ToString().Trim();
                txtRetreatSDT.Text = ds.Tables[0].Rows[0]["retreat_sdt"].ToString().Trim();
                txtRetreatEDT.Text = ds.Tables[0].Rows[0]["retreat_edt"].ToString().Trim();
                txtRetreatDesc.Text = ds.Tables[0].Rows[0]["retreat_desc"].ToString().Trim();
                txtRetreatBankNo.Text = ds.Tables[0].Rows[0]["retreat_bank_no"].ToString().Trim();
                ddl_retreat_status.SelectedValue = ds.Tables[0].Rows[0]["retreat_yn"].ToString().Trim();

                lblmoAttFile01.Text = ds.Tables[0].Rows[0]["file_nm"].ToString().Trim().Equals(string.Empty) ? string.Empty : ds.Tables[0].Rows[0]["file_nm"].ToString().Trim();

                if (ds.Tables[0].Rows[0]["file_nm"].ToString().Trim().Equals(string.Empty))
                {
                    lblmoAttFile01.Visible = false;
                    chkAttDel01.Visible = false;
                    btnFileDown.Visible = false;
                }
                else
                {
                    lblmoAttFile01.Visible = true;
                    chkAttDel01.Visible = true;
                    btnFileDown.Visible = true;
                }
            }
            else
            {
                lblmoAttFile01.Visible = false;
                chkAttDel01.Visible = false;
                btnFileDown.Visible = false;
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void SetData(string mode)
    {
        Stream uploadFileStream1 = null;
        int fileLen1 = 0;
        string fileContentType1 = string.Empty;
        string fileName1 = string.Empty;
        string file_del_yn = chkAttDel01.Checked ? "Y" : "N";
        byte[] fileBinaryData1 = null;

        char[] Separators = new char[] { '.' };
        string[] fileType;
        int sep_cnt;

        string AttYN01 = "N";
                

        if (fileAddAttachment_01.PostedFile != null && fileAddAttachment_01.PostedFile.FileName.Length != 0)
        {
            fileLen1 = fileAddAttachment_01.PostedFile.ContentLength;
            //Content Type
            fileType = fileAddAttachment_01.FileName.Split(Separators, StringSplitOptions.RemoveEmptyEntries);
            sep_cnt = fileType.Length - 1;
            fileContentType1 = fileType[sep_cnt].ToString().ToLower();
            //파일 이름
            fileName1 = fileAddAttachment_01.FileName;

            AttYN01 = "Y";
        }

        fileBinaryData1 = new byte[fileLen1];
        uploadFileStream1 = fileAddAttachment_01.PostedFile.InputStream;
        uploadFileStream1.Read(fileBinaryData1, 0, fileLen1);

        SqlParameter fileDataParameter = new SqlParameter("@RETREAT_FILE_DATA", SqlDbType.VarBinary, -1);
        fileDataParameter.Value = fileBinaryData1;

        SqlParameter[] arr = new SqlParameter[]
        {
            new SqlParameter("@RETREAT_NM", hdRetreatName.Value.Trim()),
            new SqlParameter("@RETREAT_PLACE", hdRetreatPlace.Value.Trim()),
            new SqlParameter("@RETREAT_DESC", hdRetreatDesc.Value.Trim()),
            new SqlParameter("@RETREAT_BANK", hdRetreatBankNo.Value.Trim()),
            new SqlParameter("@RETREAT_SDT", hdRetreatSDT.Value.Trim().Replace("-", "").Replace("\"", "").Replace("'", "")),
            new SqlParameter("@RETREAT_EDT", hdRetreatEDT.Value.Trim().Replace("-", "").Replace("\"", "").Replace("'", "")),
            new SqlParameter("@RETREAT_YN", hdRetreatYN.Value),
            new SqlParameter("@RETREAT_FILE_YN", AttYN01),
            new SqlParameter("@RETREAT_FILE_DEL_YN", file_del_yn),
            new SqlParameter("@RETREAT_FILE_NM", fileName1),
            new SqlParameter("@RETREAT_FILE_TYPE", fileContentType1),
            new SqlParameter("@RETREAT_FILE_SIZE", fileLen1),
            fileDataParameter,
            new SqlParameter("@UID", _login_id),
            new SqlParameter("@UIP", CodeHelper.GetUserIP),
            new SqlParameter("@SEQ", hdSeq.Value.Trim().Equals(string.Empty) ? "0" : hdSeq.Value.Trim()),
            new SqlParameter("@MODE", mode)
        };

        using (DataSet _dsInsAtt01 = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreatinfo_sav", arr))
        {
            if (!mode.Equals("D") && hdRetreatYN.Value.Equals("Y", StringComparison.OrdinalIgnoreCase))
            {
                int retreatSeq;
                object retreatSeqValue = int.TryParse(hdSeq.Value.Trim(), out retreatSeq) ? (object)retreatSeq : DBNull.Value;

                EfStoredProcedure.ExecuteNonQuery(
                    "ubfgj3.dbo.SP_retreat_set_only_active",
                    new SqlParameter("@SEQ", retreatSeqValue),
                    new SqlParameter("@RETREAT_NAME", hdRetreatName.Value.Trim()),
                    new SqlParameter("@UID", _login_id),
                    new SqlParameter("@UIP", CodeHelper.GetUserIP));
            }

            if (mode.Equals("C"))
                CodeHelper.Redirect("저장하였습니다.", "/staff/retreat");
            else if (mode.Equals("U"))
                CodeHelper.Redirect("수정하였습니다.", "/staff/retreat?mode=modify&seq=" + hdSeq.Value.Trim());
            else if (mode.Equals("D"))
                CodeHelper.Redirect("삭제하였습니다!", "/staff/retreat");
        }
    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            DataSet ds1 = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreat_name_duplicate_check",
                new SqlParameter("@RETREAT_NAME", hdRetreatName.Value.ToString().Trim()),
                new SqlParameter("@SEQ", hdSeq.Value.ToString().Trim().Equals(string.Empty) ? (object)DBNull.Value : hdSeq.Value.ToString().Trim()));

            if (ds1.Tables[0].Rows.Count > 0)
            {
                CodeHelper.Redirect("동일한 이름으로 저장된 수양회가 있습니다.", "/staff/retreat");

            }
            else
            {
                if (hdSeq.Value.ToString().Trim().Equals(string.Empty))
                    SetData("C");
                else
                {
                    DataSet dsCheck = EfStoredProcedure.ExecuteDataSet(
                        "ubfgj3.dbo.SP_retreat_active_other_check",
                        new SqlParameter("@SEQ", hdSeq.Value.Trim()));

                    if (hdRetreatYN.Value.Equals("N") && dsCheck.Tables[0].Rows.Count == 0)
                    {
                        divSaveAlert.Visible = true;
                        lblAlert.Text = "사용여부가 '사용'인 수양회가 반드시 하나 있어야 합니다.";
                        ddl_retreat_status.SelectedValue = hdRetreatYN.Value;
                        return;
                    }
                    else
                        SetData("U");
                }
                    
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
            DataSet dsCheck = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreat_delete_dependency_check",
                new SqlParameter("@SEQ", hdSeq.Value.Trim()));

            if (dsCheck.Tables[0].Rows.Count > 0)
            {
                divSaveAlert.Visible = true;
                lblAlert.Text = "위 수양회 정보로 저장된 자료(요회구성원, 수양회비구분 등)가 있으므로 삭제할 수 없습니다. (변경은 가능함)";
                btnDel.Enabled = false;
                return;
            }
            else
                SetData("D");
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
            e.Row.Attributes.Add("onclick", "javascript:detailview_retreat('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }




    protected void btnFileDown_Click(object sender, EventArgs e)
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_retreat_file_get",
                new SqlParameter("@SEQ", hdSeq.Value.ToString().Trim()));

            string fileName = ds.Tables[0].Rows[0]["file_nm"].ToString();
            byte[] byteFile = (byte[])ds.Tables[0].Rows[0]["file_data"];

            Response.Clear();
            Response.ContentType = "Application/UnKnown";//파일열기,저장,취소확인창띄우기"Application/Octet-Stream"

            Response.AppendHeader("Content-Disposition", "Attachment; Filename=" + Server.UrlEncode(fileName));
            Response.AppendHeader("Content-Length", byteFile.Length.ToString());
            Response.BinaryWrite(byteFile);
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('다운로드 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }
}
