using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class staff_history : Page
{
    private DataTable records;

    protected override void OnInit(EventArgs e)
    {
        ViewStateUserKey = Session.SessionID;
        base.OnInit(e);
        string role = (UserInfo.UserRole ?? String.Empty).ToLowerInvariant();
        if (role != "admin" && role != "manager")
            throw new HttpException(403, "접근 권한이 없습니다.");
    }

    private DataTable Records
    {
        get
        {
            if (records == null)
            {
                records = EfStoredProcedure.ExecuteDataSet("dbo.SP_staff_history_get_list").Tables[0];
                foreach (DataRow row in records.Rows)
                {
                    if (row.IsNull("staff_names"))
                    {
                        Match owner = Regex.Match(row["bank_info"].ToString(), @"예금주\s*[:：]?\s*([^()（）\r\n<>]+)");
                        row["staff_names"] = owner.Success ? owner.Groups[1].Value.Trim() : String.Empty;
                    }
                }
            }
            return records;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                ddlYear.Items.Add(new ListItem("전체 연도", ""));
                foreach (DataRow row in Records.Rows)
                {
                    string year = row["retreat_year"].ToString();
                    if (ddlYear.Items.FindByValue(year) == null)
                        ddlYear.Items.Add(new ListItem(year, year));
                }
                BindRetreats();
                BindCards();
            }
            catch (Exception ex) { ReportError(ex); }
        }
    }

    private void BindRetreats()
    {
        ddlRetreat.Items.Clear();
        ddlRetreat.Items.Add(new ListItem("전체 수양회", ""));
        foreach (DataRow row in Records.Rows)
            if (MatchesYear(row))
                ddlRetreat.Items.Add(new ListItem(row["retreat_name"].ToString(), row["seq"].ToString()));
    }

    private bool MatchesYear(DataRow row)
    {
        return ddlYear.SelectedValue == "" || row["retreat_year"].ToString() == ddlYear.SelectedValue;
    }

    private void BindCards()
    {
        DataTable filtered = Records.Clone();
        foreach (DataRow row in Records.Rows)
            if (MatchesYear(row) && (ddlRetreat.SelectedValue == "" || row["seq"].ToString() == ddlRetreat.SelectedValue))
                filtered.ImportRow(row);
        rptHistory.DataSource = filtered;
        rptHistory.DataBind();
        litCount.Text = filtered.Rows.Count == 0 ? "등록된 수양회가 없습니다." : "총 " + filtered.Rows.Count + "개 수양회 · 최근 수양회순";
    }

    protected void YearChanged(object sender, EventArgs e)
    {
        pnlEdit.Visible = false;
        lblMessage.Text = "";
        try { BindRetreats(); BindCards(); }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void RetreatChanged(object sender, EventArgs e)
    {
        pnlEdit.Visible = false;
        lblMessage.Text = "";
        try { BindCards(); }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void EditRecord(object sender, RepeaterCommandEventArgs e)
    {
        if (e.CommandName != "EditRecord") return;
        try
        {
            foreach (DataRow row in Records.Rows)
                if (row["seq"].ToString() == e.CommandArgument.ToString())
                {
                    hdRetreat.Value = row["seq"].ToString();
                    litEditTitle.Text = row["retreat_name"].ToString();
                    txtStaff.Text = row["staff_names"].ToString();
                    txtBank.Text = row["bank_info"].ToString();
                    pnlEdit.Visible = true;
                    lblMessage.Text = "";
                    txtStaff.Focus();
                    break;
                }
        }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void Save(object sender, EventArgs e)
    {
        int seq;
        if (!pnlEdit.Visible || !Int32.TryParse(hdRetreat.Value, out seq)) return;
        if (txtStaff.Text.Trim().Length > 300 || txtBank.Text.Trim().Length > 300)
        {
            lblMessage.Text = "실무자와 실무통장은 각각 300자 이내로 입력해 주세요.";
            return;
        }
        try
        {
            EfStoredProcedure.ExecuteNonQuery("dbo.SP_staff_history_save",
                new SqlParameter("@RetreatSeq", seq),
                new SqlParameter("@StaffNames", SqlDbType.NVarChar, 300) { Value = txtStaff.Text.Trim() },
                new SqlParameter("@BankInfo", SqlDbType.NVarChar, 300) { Value = txtBank.Text.Trim() });
            records = null;
            BindCards();
            pnlEdit.Visible = false;
            lblMessage.Text = "실무자 및 실무통장 정보를 저장했습니다.";
        }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void Cancel(object sender, EventArgs e) { pnlEdit.Visible = false; lblMessage.Text = ""; }
    protected string Display(object value) { return String.IsNullOrWhiteSpace(Convert.ToString(value)) ? "미등록" : Convert.ToString(value); }
    private void ReportError(Exception ex)
    {
        System.Diagnostics.Trace.TraceError("Staff history: {0}", ex);
        lblMessage.Text = "정보를 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.";
    }
}
