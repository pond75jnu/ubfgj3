using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;

public partial class staff_expenses : System.Web.UI.Page
{
    string _auth = string.Empty;
    string _login_id = string.Empty;
    string _path = CodeHelper.GetCurrentCanonicalPath();
    private string _domain = HttpContext.Current.Request.Url.Host;

    #region 이미지폴더 기본위치 설정    
    string _image_path_product = "F:\\home\\ubfgj3\\www\\_attatch\\";
    string _image_path_local = HttpContext.Current.Server.MapPath("~/_attatch");
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {   
        _auth = UserInfo.UserRole;
        _login_id = UserInfo.UserID;
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);


        if (!Page.IsPostBack)
        {
            LoadRetreats();

            id_left_menu.mRetreat = ddl_retreat.SelectedValue;

            if ((_domain.ToLower().Equals("localhost")) || (_domain.ToLower().Equals("127.0.0.1")) || (_domain.ToLower().Equals("www.devubfgj3.kr")) || (_domain.ToLower().Equals("devubfgj3.kr")))
            {
                hdImgPath.Value = _image_path_local + "\\" + ddl_retreat.SelectedValue;
                hdImgPath_Temp.Value = _image_path_local + "\\temp";                
            }                
            else
            {
                hdImgPath.Value = _image_path_product + "\\" + ddl_retreat.SelectedValue;
                hdImgPath_Temp.Value = _image_path_product + "\\temp";
            }
                

            if (!Directory.Exists(hdImgPath.Value))
                Directory.CreateDirectory(hdImgPath.Value);

            if (!Directory.Exists(hdImgPath_Temp.Value))
                Directory.CreateDirectory(hdImgPath_Temp.Value);


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
                        Response.Redirect(_path, false);
                }
                else
                    PageMode("LIST");
            }
            else
                PageMode("LIST");
            #endregion
        }


    }

    protected void PageMode(string _mode)
    {
        switch (_mode)
        {
            case "LIST":
                divList.Visible = true;
                divWriteModify.Visible = false;
                btnExportExcel.Visible = false;
                btnPrintAll.Visible = false;

                GetList();

                if (ddl_retreat.Items.Count > 0)
                    btnNew.Visible = true;
                else
                    btnNew.Visible = false;

                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;
                btnPrintDetail.Visible = false;

                hdSeq.Value = string.Empty;
                break;
            case "WRITE":
                divList.Visible = false;
                divWriteModify.Visible = true;
                btnPrintAll.Visible = false;

                btnNew.Visible = false;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = false;
                btnPrintDetail.Visible = false;
                btnExportExcel.Visible = false;

                hdSeq.Value = string.Empty;
                lblWriteModeTitle.Text = "신규입력";

                LoadCashTypes();
                break;
            case "MODIFY":
                divList.Visible = false;
                divWriteModify.Visible = true;

                GetDetail();

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = true;
                btnSave.Visible = true;
                btnDel.Visible = true;
                btnPrintDetail.Visible = true;
                btnExportExcel.Visible = false;
                btnPrintAll.Visible = false;

                lblWriteModeTitle.Text = "내용수정";

                LoadCashTypes();
                break;
            default:
                divList.Visible = true;
                divWriteModify.Visible = false;
                btnExportExcel.Visible = false;

                GetList();

                btnNew.Visible = true;
                btnModify.Visible = false;
                btnList.Visible = false;
                btnSave.Visible = false;
                btnDel.Visible = false;
                btnPrintDetail.Visible = false;
                btnPrintAll.Visible = false;

                hdSeq.Value = string.Empty;
                break;
        }
    }

    protected void LoadRetreats()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_retreat_get_list",
                new SqlParameter("@top_count", SqlDbType.Int) { Value = 1 },
                new SqlParameter("@active_only", SqlDbType.Bit) { Value = true });

            if (ds.Tables[0].Rows.Count > 0)
            {
                ddl_retreat.DataSource = ds;
                ddl_retreat.DataBind();

                if (!CodeHelper.RetreatCode.Equals(string.Empty))
                    ddl_retreat.SelectedValue = CodeHelper.RetreatCode;

                ddl_retreat.Enabled = false;
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보가 없습니다. (관리자 문의)');</script>");
                return;
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('수양회 정보 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void LoadCashTypes()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_cash_item_get_options",
                new SqlParameter("@cash_type", SqlDbType.Int) { Value = 2 },
                new SqlParameter("@exclude_retreat_dues", SqlDbType.Bit) { Value = false });


            if (ds.Tables[0].Rows.Count > 0)
            {
                ddl_cash_item.DataSource = ds;
                ddl_cash_item.DataBind();

                ddl_cash_item.Items.Insert(0, new ListItem("- 선택하세요 -", "-1"));

            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('지출항목 정보가 없습니다. (관리자 문의)');</script>");
                btnSave.Enabled = false;
                btnDel.Enabled = false;
                return;
            }


        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('지출항목 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetList()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_payment_get_list",
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(ddl_retreat.SelectedValue) },
                new SqlParameter("@cash_type", SqlDbType.Int) { Value = 2 },
                new SqlParameter("@excel_yn", SqlDbType.Char, 1) { Value = "N" });

            gvList.DataSource = ds;
            gvList.DataBind();

            if (ds.Tables[0].Rows.Count > 0)
            {
                btnExportExcel.Visible = true;

                if (ds.Tables[0].Rows.Count > 1) //목록이 1개 이상인 경우
                    btnPrintAll.Visible = true;
                else
                    btnPrintAll.Visible = false;

                lblSum.Text = "· 총 지출: " + ds.Tables[1].Rows[0]["payment_all_format"].ToString();
            }
            else
                btnExportExcel.Visible = false;
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('지출항목 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    protected void GetDetail()
    {
        try
        {
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_staff_payment_get_detail",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            if (ds.Tables[0].Rows.Count > 0)
            {
                ddl_cash_item.SelectedValue = ds.Tables[0].Rows[0]["cash_item_seq"].ToString().Trim();
                txtPaymentNM.Text = ds.Tables[0].Rows[0]["payment_item"].ToString().Trim();
                txtPayment.Text = ds.Tables[0].Rows[0]["payment_format_comma"].ToString().Trim();
                txtPaymentDT.Text = ds.Tables[0].Rows[0]["payment_dt"].ToString().Trim();
                txtPaymentDesc.Text = ds.Tables[0].Rows[0]["payment_item_desc"].ToString().Trim();

                if (ds.Tables[0].Rows[0]["file_nm"].ToString().Trim().Equals(string.Empty))
                {                    
                    divAttatchImageDelete.Visible = false;
                    divAttatchImage.Visible = false;
                }
                else
                {
                    hdImgUrl.Value = ds.Tables[0].Rows[0]["file_url"].ToString().Trim();
                    divAttatchImageDelete.Visible = true;
                    divAttatchImage.Visible = true;

                    AttatchImage.ImageUrl= ds.Tables[0].Rows[0]["file_url"].ToString().Trim();
                    aAttatchImage.HRef = ds.Tables[0].Rows[0]["file_url"].ToString().Trim();                                        
                }
            }

        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('세부 조회 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
        }
    }

    

    protected void SetData(string mode)
    {
        string _file_org_full_nm = string.Empty;
        string _file_org_nm = string.Empty;
        string _file_org_extention = string.Empty;
        if (imgUpload.PostedFile != null && imgUpload.PostedFile.FileName.Length != 0)
        {
            _file_org_full_nm = Path.GetFileName(imgUpload.PostedFile.FileName);
            _file_org_nm = Path.GetFileNameWithoutExtension(imgUpload.PostedFile.FileName);
            _file_org_extention = Path.GetExtension(imgUpload.PostedFile.FileName);
        }

        string _file_nm = _file_org_nm.Trim().Equals(string.Empty) ? string.Empty : Guid.NewGuid().ToString();
        string _file_url = _file_nm.Trim().Equals(string.Empty) ? string.Empty : "/_attatch/" + ddl_retreat.SelectedValue + "/" + _file_nm + _file_org_extention;
        string _file_full_nm_new = _file_nm + _file_org_extention;

        string sFileFull_temp = hdImgPath_Temp.Value + string.Format(@"\{0}", _file_full_nm_new);
        string sFileFull = _file_org_nm.Trim().Equals(string.Empty) ? string.Empty : hdImgPath.Value + string.Format(@"\{0}", _file_full_nm_new);

        sFileFull_temp = sFileFull_temp.Replace("\\\\", "\\");
        sFileFull = sFileFull.Replace("\\\\", "\\");

        string _attatch_file_full_path = string.Empty;
        string _del_file_yn = string.Empty;

        if (mode.Equals("C"))
        {
            decimal _expense = CodeHelper.ParsePositiveWholeWon(hdExpenses.Value, "지출비용");

            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_payment_insert",
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(hdRetreat.Value.Trim()) },
                new SqlParameter("@cash_item_seq", SqlDbType.Int) { Value = Convert.ToInt32(hdCashCode.Value) },
                new SqlParameter("@payment_dt", SqlDbType.VarChar, 8) { Value = hdExpensesDT.Value.Trim().Replace("-", "") },
                new SqlParameter("@payment_item", SqlDbType.NVarChar, 200) { Value = hdExpensesNM.Value.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@payment", SqlDbType.Decimal) { Precision = 18, Scale = 0, Value = _expense },
                new SqlParameter("@payment_item_desc", SqlDbType.NVarChar, -1) { Value = hdExpensesDesc.Value.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@file_nm", SqlDbType.NVarChar, 100) { Value = _file_nm },
                new SqlParameter("@file_type", SqlDbType.NVarChar, 20) { Value = _file_org_extention },
                new SqlParameter("@file_url", SqlDbType.NVarChar, 500) { Value = _file_url },
                new SqlParameter("@file_path", SqlDbType.NVarChar, 1000) { Value = sFileFull },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });

            if (imgUpload.PostedFile != null && imgUpload.PostedFile.FileName.Length != 0)
            {
                SetFile(sFileFull_temp, sFileFull);
            }

            CodeHelper.Redirect("저장하였습니다.", _path);
        }
        else if (mode.Equals("U"))
        {
            decimal _expense = CodeHelper.ParsePositiveWholeWon(hdExpenses.Value, "지출비용");

            _attatch_file_full_path = CodeHelper.GetFilePath(hdSeq.Value.ToString().Trim());

            //새로 파일 첨부시
            if (imgUpload.PostedFile != null && imgUpload.PostedFile.FileName.Length != 0)
            {
                _del_file_yn = "A";

                //기존 파일 삭제
                if (File.Exists(_attatch_file_full_path))
                {
                    File.Delete(_attatch_file_full_path);
                }

                SetFile(sFileFull_temp, sFileFull);

            }
            else
            {
                _del_file_yn = chkAttDel01.Checked ? "Y" : "N";

                if (chkAttDel01.Checked)
                {
                    //파일 삭제
                    if (File.Exists(_attatch_file_full_path))
                    {
                        File.Delete(_attatch_file_full_path);
                    }
                }
            }
            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_payment_update",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) },
                new SqlParameter("@retreat", SqlDbType.Int) { Value = Convert.ToInt32(hdRetreat.Value.Trim()) },
                new SqlParameter("@cash_item_seq", SqlDbType.Int) { Value = Convert.ToInt32(hdCashCode.Value) },
                new SqlParameter("@payment_dt", SqlDbType.VarChar, 8) { Value = hdExpensesDT.Value.Trim().Replace("-", "") },
                new SqlParameter("@payment_item", SqlDbType.NVarChar, 200) { Value = hdExpensesNM.Value.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@payment", SqlDbType.Decimal) { Precision = 18, Scale = 0, Value = _expense },
                new SqlParameter("@payment_item_desc", SqlDbType.NVarChar, -1) { Value = hdExpensesDesc.Value.Trim().Replace("\"", "").Replace("'", "") },
                new SqlParameter("@del_file_yn", SqlDbType.Char, 1) { Value = _del_file_yn },
                new SqlParameter("@file_nm", SqlDbType.NVarChar, 100) { Value = _file_nm },
                new SqlParameter("@file_type", SqlDbType.NVarChar, 20) { Value = _file_org_extention },
                new SqlParameter("@file_url", SqlDbType.NVarChar, 500) { Value = _file_url },
                new SqlParameter("@file_path", SqlDbType.NVarChar, 1000) { Value = sFileFull },
                new SqlParameter("@user_id", SqlDbType.NVarChar, 50) { Value = _login_id },
                new SqlParameter("@user_ip", SqlDbType.NVarChar, 45) { Value = CodeHelper.GetUserIP });
            CodeHelper.Redirect("수정하였습니다.", _path + "?mode=modify&seq=" + hdSeq.Value.Trim());
        }
        else if (mode.Equals("D"))
        {
            _attatch_file_full_path = CodeHelper.GetFilePath(hdSeq.Value.ToString().Trim());

            //파일 삭제
            if (File.Exists(_attatch_file_full_path))
            {
                File.Delete(_attatch_file_full_path);
            }

            EfStoredProcedure.ExecuteNonQuery(
                "ubfgj3.dbo.SP_staff_payment_delete",
                new SqlParameter("@seq", SqlDbType.Int) { Value = Convert.ToInt32(hdSeq.Value.ToString().Trim()) });

            CodeHelper.Redirect("삭제하였습니다!", _path);

        }
    }



    protected void SetFile(string sFileFull_temp, string sFileFull)
    {
        int _temp_img_width = 0;
        int _new_width = 0;
        int _new_height = 0;


        int _default_width = 1200; //리사이즈 기준사이즈
        //int _default_width = 800; //리사이즈 기준사이즈

        Bitmap img_temp = null;
        Bitmap resize_img = null;
        Graphics g = null;


        //임시 저장
        imgUpload.PostedFile.SaveAs(sFileFull_temp);

        //임시저장한 이미지를 객체로 생성
        img_temp = new Bitmap(sFileFull_temp);


        //임시저장한 파일의 가로 크기 확인
        _temp_img_width = img_temp.Width;

        if (_temp_img_width > _default_width)
            _new_width = _default_width; //새로운 크기로 만들 이미지 생성
        else
            _new_width = _temp_img_width;

        _new_height = (_new_width * img_temp.Height) / img_temp.Width;

        //새로운 크기로 만들 이미지 생성
        _new_width = _default_width;
        _new_height = (_new_width * img_temp.Height) / img_temp.Width;

        resize_img = new Bitmap(_new_width, _new_height);

        //GDI+를 이용하여 리사이즈된 이미지 생성
        g = Graphics.FromImage(resize_img);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.DrawImage(img_temp, new Rectangle(0, 0, _new_width, _new_height));

        //가로 길이가 더 긴 경우에는 이미지 90도 회전
        if (_new_width > _new_height)
        {
            resize_img = fnRotateImage(resize_img, 90);
            g.DrawImage(img_temp, new Rectangle(0, 0, resize_img.Width, resize_img.Height));

        }

        //리사이즈된 이미지 저장
        resize_img.Save(sFileFull);

        //메모리 해제
        img_temp.Dispose();
        resize_img.Dispose();


        //임시저장한 파일 삭제
        if (File.Exists(sFileFull_temp))
        {
            File.Delete(sFileFull_temp);
        }
    }

    protected Bitmap fnRotateImage(Bitmap b, float angle)
    {
        Bitmap returnBitmap = new Bitmap(b.Height, b.Width);
        Graphics g = Graphics.FromImage(returnBitmap);
        g.TranslateTransform((float)returnBitmap.Width / 2, (float)returnBitmap.Height / 2);
        g.RotateTransform(angle);

        g.TranslateTransform(-(float)b.Width / 2, -(float)b.Height / 2);
        g.DrawImage(b, new Point(0, 0));

        return returnBitmap;
    }



    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            if (hdSeq.Value.ToString().Trim().Equals(string.Empty))
                SetData("C");
            else
                SetData("U");

        }
        catch (Exception ex)
        {
            //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Alert", "<script>alert('저장 중 에러 발생 : " + Server.HtmlEncode(ex.Message) + @"');</script>");
            Response.Write(ex);
        }

    }

    protected void btnDel_Click(object sender, EventArgs e)
    {
        try
        {
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
            e.Row.Attributes.Add("onclick", "javascript:detailview_expenses('" + e.Row.Cells[1].Text + "');");
            e.Row.Attributes.Add("onmouseover", "javascript:setMouseOverColor(this);");
            e.Row.Attributes.Add("onmouseout", "javascript:setMouseOutColor(this);");

        }
    }

    protected void ddl_retreat_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetList();
    }

}
