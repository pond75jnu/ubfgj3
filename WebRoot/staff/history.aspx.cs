using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class staff_history : Page
{
    private DataTable records;
    protected int TotalCount { get; private set; }

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
                BindList();
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

    private void BindList()
    {
        DataTable filtered = Records.Clone();
        foreach (DataRow row in Records.Rows)
            if (MatchesYear(row) && (ddlRetreat.SelectedValue == "" || row["seq"].ToString() == ddlRetreat.SelectedValue))
                filtered.ImportRow(row);
        int lastPage = Math.Max(0, (filtered.Rows.Count - 1) / gvList.PageSize);
        gvList.PageIndex = Math.Min(gvList.PageIndex, lastPage);
        TotalCount = filtered.Rows.Count;
        gvList.DataSource = filtered;
        gvList.DataBind();
        litCount.Text = "총 " + filtered.Rows.Count + "건 · 페이지당 15개";
        if (filtered.Rows.Count > 0)
            litCount.Text += " · " + (gvList.PageIndex + 1) + " / " + gvList.PageCount + " 페이지";
    }

    protected void YearChanged(object sender, EventArgs e)
    {
        gvList.PageIndex = 0;
        lblMessage.Text = "";
        try { BindRetreats(); BindList(); }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void RetreatChanged(object sender, EventArgs e)
    {
        gvList.PageIndex = 0;
        lblMessage.Text = "";
        try { BindList(); }
        catch (Exception ex) { ReportError(ex); }
    }

    protected void PageChanged(object sender, GridViewPageEventArgs e)
    {
        gvList.PageIndex = Math.Max(0, e.NewPageIndex);
        lblMessage.Text = "";
        try { BindList(); }
        catch (Exception ex) { ReportError(ex); }
    }

    protected string Display(object value) { return String.IsNullOrWhiteSpace(Convert.ToString(value)) ? "미등록" : Convert.ToString(value); }
    private void ReportError(Exception ex)
    {
        System.Diagnostics.Trace.TraceError("Staff history: {0}", ex);
        lblMessage.Text = "정보를 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.";
    }
}
