using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class staff_mealstatus : Page
{
    private string _retreatCode = String.Empty;
    private string _mode = "summary";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!CanManageMeals())
        {
            DenyAccess();
            return;
        }

        lblPageTitle.Text = CodeHelper.GetPagetitle(CodeHelper.GetCurrentCanonicalPath());
        if (String.IsNullOrWhiteSpace(lblPageTitle.Text))
        {
            lblPageTitle.Text = "식사수량파악";
        }

        _mode = String.Equals(Request.QueryString["mode"], "config", StringComparison.OrdinalIgnoreCase)
            ? "config"
            : "summary";

        SetTabs();
        if (!LoadActiveRetreat())
        {
            pnlSummary.Visible = false;
            pnlConfig.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            if (_mode == "config")
            {
                BindConfig();
            }
            else
            {
                BindSummary();
            }

            if (String.Equals(Request.QueryString["saved"], "1", StringComparison.Ordinal))
            {
                ShowMessage("식사 제공 설정을 저장했습니다.", false);
            }
        }
        else if (!String.IsNullOrWhiteSpace(Request.Form["detailGroup"]))
        {
            BindSummary();
            int belong;
            if (Int32.TryParse(Request.Form["detailGroup"], out belong))
            {
                BindDetail(belong);
            }
        }
    }

    protected void btnSaveConfig_Click(object sender, EventArgs e)
    {
        if (!CanManageMeals())
        {
            DenyAccess();
            return;
        }
        SaveConfig(false);
    }

    protected void btnForceSave_Click(object sender, EventArgs e)
    {
        if (!CanManageMeals())
        {
            DenyAccess();
            return;
        }
        SaveConfig(true);
    }

    private bool CanManageMeals()
    {
        string role = (UserInfo.UserRole ?? String.Empty).Trim().ToLowerInvariant();
        return role == "manager" || role == "admin";
    }

    private void DenyAccess()
    {
        Response.Redirect("/", false);
        Context.ApplicationInstance.CompleteRequest();
    }

    private void SetTabs()
    {
        tabSummary.Attributes["class"] = _mode == "summary" ? "is-active" : String.Empty;
        tabConfig.Attributes["class"] = _mode == "config" ? "is-active" : String.Empty;
        if (_mode == "summary")
        {
            tabSummary.Attributes["aria-current"] = "page";
        }
        else
        {
            tabConfig.Attributes["aria-current"] = "page";
        }
    }

    private bool LoadActiveRetreat()
    {
        try
        {
            DataSet data = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_get");
            if (data.Tables.Count == 0 || data.Tables[0].Rows.Count == 0)
            {
                ShowMessage("현재 사용 중인 수양회가 없습니다. 수양회 설정을 확인하세요.", true);
                return false;
            }

            ddlRetreat.DataSource = data.Tables[0];
            ddlRetreat.DataBind();
            ddlRetreat.Enabled = false;
            ddlRetreat.Attributes["aria-disabled"] = "true";
            _retreatCode = Convert.ToString(data.Tables[0].Rows[0]["seq"], CultureInfo.InvariantCulture);
            return !String.IsNullOrWhiteSpace(_retreatCode);
        }
        catch (Exception ex)
        {
            ShowMessage("수양회 정보를 불러오지 못했습니다. " + Server.HtmlEncode(ex.Message), true);
            return false;
        }
    }

    private void BindSummary()
    {
        pnlSummary.Visible = true;
        pnlConfig.Visible = false;

        try
        {
            DataSet data = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_summary_get",
                new SqlParameter("@RETREAT", _retreatCode));

            if (data.Tables.Count < 2)
            {
                throw new InvalidOperationException("식사수량 집계 결과가 올바르지 않습니다.");
            }

            litSummary.Text = BuildSummaryHtml(data.Tables[0], data.Tables[1]);
        }
        catch (Exception ex)
        {
            litSummary.Text = String.Empty;
            ShowMessage("식사수량 현황을 불러오지 못했습니다. " + Server.HtmlEncode(ex.Message), true);
        }
    }

    private string BuildSummaryHtml(DataTable groups, DataTable counts)
    {
        if (groups.Rows.Count == 0)
        {
            return "<div class='site-empty-state'>조회할 요회가 없습니다.</div>";
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class='site-meal-summary-grid'>");

        foreach (DataRow group in groups.Rows)
        {
            int belong = Convert.ToInt32(group["belong"], CultureInfo.InvariantCulture);
            bool isTotal = Convert.ToInt32(group["is_total"], CultureInfo.InvariantCulture) == 1;
            string groupName = Server.HtmlEncode(Convert.ToString(group["belong_nm"]));
            string status = Convert.ToString(group["submission_status"]);

            html.Append("<article class='site-meal-summary-card'>");
            html.Append("<header class='site-meal-card-header'><div>");
            if (isTotal)
            {
                html.Append("<h3>").Append(groupName).Append("</h3>");
            }
            else
            {
                html.Append("<button type='submit' class='site-meal-group-link' name='detailGroup' value='")
                    .Append(belong.ToString(CultureInfo.InvariantCulture))
                    .Append("'>").Append(groupName).Append("</button>");
            }

            html.Append("<p>");
            if (isTotal)
            {
                html.Append("개인 선택 ")
                    .Append(Convert.ToInt32(group["selected_member_count"], CultureInfo.InvariantCulture))
                    .Append("명 / 직접입력 ")
                    .Append(Convert.ToInt32(group["manual_group_count"], CultureInfo.InvariantCulture))
                    .Append("개 요회 / 명단 ")
                    .Append(Convert.ToInt32(group["member_count"], CultureInfo.InvariantCulture))
                    .Append("명");
            }
            else if (String.Equals(Convert.ToString(group["entry_mode"]), "M", StringComparison.Ordinal))
            {
                html.Append("수량 직접입력 / 명단 0명");
            }
            else
            {
                html.Append("식사 선택 ")
                    .Append(Convert.ToInt32(group["selected_member_count"], CultureInfo.InvariantCulture))
                    .Append("명 / 명단 ")
                    .Append(Convert.ToInt32(group["member_count"], CultureInfo.InvariantCulture))
                    .Append("명");
            }
            html.Append("</p></div>");

            if (isTotal)
            {
                html.Append("<span class='site-meal-status-badge is-summary'>제출 요회 ")
                    .Append(Convert.ToInt32(group["submitted_group_count"], CultureInfo.InvariantCulture))
                    .Append("/")
                    .Append(Convert.ToInt32(group["group_count"], CultureInfo.InvariantCulture))
                    .Append("</span>");
            }
            else
            {
                html.Append(BuildStatusBadge(status));
            }
            html.Append("</header>");

            DataRow[] groupCounts = counts.Select("belong = " + belong.ToString(CultureInfo.InvariantCulture), "meal_date ASC, meal_order ASC");
            html.Append(BuildCountTable(groupCounts));

            if (!isTotal && !group.IsNull("submitted_dt"))
            {
                DateTime submitted = DateTime.SpecifyKind(Convert.ToDateTime(group["submitted_dt"], CultureInfo.InvariantCulture), DateTimeKind.Utc).ToLocalTime();
                html.Append("<footer class='site-meal-card-footer'>마지막 저장 ")
                    .Append(Server.HtmlEncode(submitted.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture)))
                    .Append("</footer>");
            }

            html.Append("</article>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private string BuildCountTable(DataRow[] rows)
    {
        if (rows.Length == 0)
        {
            return "<div class='site-empty-state'>식사 일정이 없습니다.</div>";
        }

        List<string> dates = new List<string>();
        Dictionary<string, DataRow> cells = new Dictionary<string, DataRow>(StringComparer.Ordinal);
        foreach (DataRow row in rows)
        {
            string date = Convert.ToString(row["meal_date"]);
            string type = Convert.ToString(row["meal_type"]);
            if (!dates.Contains(date))
            {
                dates.Add(date);
            }
            cells[date + "|" + type] = row;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class='site-meal-table-scroll'><table class='site-meal-count-table'><thead><tr><th>날짜</th><th>아침</th><th>점심</th><th>저녁</th><th>합계</th></tr></thead><tbody>");
        int breakfastTotal = 0;
        int lunchTotal = 0;
        int dinnerTotal = 0;

        foreach (string date in dates)
        {
            int dayTotal = 0;
            html.Append("<tr><th scope='row'>").Append(Server.HtmlEncode(MealPrecheckHelper.FormatDate(date))).Append("</th>");
            foreach (string type in new[] { "B", "L", "D" })
            {
                DataRow cell = cells[date + "|" + type];
                bool provided = Convert.ToString(cell["provide_yn"]) == "Y";
                if (!provided)
                {
                    html.Append("<td><span class='site-meal-not-provided' aria-label='제공 안 함'>-</span></td>");
                    continue;
                }

                int count = cell.IsNull("meal_count") ? 0 : Convert.ToInt32(cell["meal_count"], CultureInfo.InvariantCulture);
                dayTotal += count;
                if (type == "B") breakfastTotal += count;
                if (type == "L") lunchTotal += count;
                if (type == "D") dinnerTotal += count;
                html.Append("<td>");
                AppendPortion(html, count);
                html.Append("</td>");
            }
            html.Append("<td class='site-meal-total-cell'>");
            AppendPortion(html, dayTotal);
            html.Append("</td></tr>");
        }

        html.Append("</tbody><tfoot><tr><th scope='row'>기간 합계</th><td>");
        AppendPortion(html, breakfastTotal);
        html.Append("</td><td>");
        AppendPortion(html, lunchTotal);
        html.Append("</td><td>");
        AppendPortion(html, dinnerTotal);
        html.Append("</td><td class='site-meal-total-cell'>");
        AppendPortion(html, breakfastTotal + lunchTotal + dinnerTotal);
        html.Append("</td></tr></tfoot></table></div>");
        return html.ToString();
    }

    private void AppendPortion(StringBuilder html, int count)
    {
        html.Append("<span class='site-meal-count-value'>")
            .Append(count)
            .Append("</span><span class='site-meal-count-unit'>인분</span>");
    }

    private string BuildStatusBadge(string status)
    {
        if (status == "COMPLETED")
        {
            return "<span class='site-meal-status-badge is-complete'>제출</span>";
        }
        if (status == "RECHECK_REQUIRED")
        {
            return "<span class='site-meal-status-badge is-recheck'>재확인 필요</span>";
        }
        return "<span class='site-meal-status-badge is-empty'>미제출</span>";
    }

    private void BindConfig()
    {
        pnlSummary.Visible = false;
        pnlConfig.Visible = true;

        try
        {
            DataSet data = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_service_effective_get",
                new SqlParameter("@RETREAT", _retreatCode));

            if (data.Tables.Count == 0 || data.Tables[0].Rows.Count == 0)
            {
                litConfig.Text = "<div class='site-empty-state'>설정할 식사 일정이 없습니다.</div>";
                btnSaveConfig.Enabled = false;
                return;
            }

            DataTable schedule = data.Tables[0];
            hdConfigRevision.Value = Convert.ToString(schedule.Rows[0]["config_revision"], CultureInfo.InvariantCulture);
            pnlDefaultNotice.Visible = schedule.Select("saved_yn = 'Y'").Length == 0;
            litConfig.Text = BuildConfigHtml(schedule);
        }
        catch (Exception ex)
        {
            litConfig.Text = String.Empty;
            btnSaveConfig.Enabled = false;
            ShowMessage("식사 제공 설정을 불러오지 못했습니다. " + Server.HtmlEncode(ex.Message), true);
        }
    }

    private string BuildConfigHtml(DataTable schedule)
    {
        List<string> dates = new List<string>();
        Dictionary<string, DataRow> cells = new Dictionary<string, DataRow>(StringComparer.Ordinal);
        foreach (DataRow row in schedule.Rows)
        {
            string date = Convert.ToString(row["meal_date"]);
            string type = Convert.ToString(row["meal_type"]);
            if (!dates.Contains(date)) dates.Add(date);
            cells[date + "|" + type] = row;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<table class='site-meal-config-table'><thead><tr><th class='site-meal-sticky-col'>식사</th>");
        foreach (string date in dates)
        {
            html.Append("<th scope='col' aria-label='")
                .Append(Server.HtmlEncode(MealPrecheckHelper.FormatDateLong(date)))
                .Append("'>").Append(Server.HtmlEncode(MealPrecheckHelper.FormatDate(date))).Append("</th>");
        }
        html.Append("</tr></thead><tbody>");

        foreach (string type in new[] { "B", "L", "D" })
        {
            html.Append("<tr><th scope='row' class='site-meal-sticky-col'>")
                .Append(MealPrecheckHelper.GetMealName(type)).Append("</th>");
            foreach (string date in dates)
            {
                bool isChecked = Convert.ToString(cells[date + "|" + type]["provide_yn"]) == "Y";
                string name = "meal_config_" + date + "_" + type;
                html.Append("<td><label class='site-meal-check-label'><input type='checkbox' name='")
                    .Append(name).Append("' value='Y'")
                    .Append(isChecked ? " checked='checked'" : String.Empty)
                    .Append(" /><span>").Append(MealPrecheckHelper.GetMealName(type)).Append(" 제공</span></label></td>");
            }
            html.Append("</tr>");
        }

        html.Append("</tbody></table>");
        return html.ToString();
    }

    private void SaveConfig(bool force)
    {
        _mode = "config";
        SetTabs();
        pnlSummary.Visible = false;
        pnlConfig.Visible = true;
        pnlForceSave.Visible = false;

        try
        {
            DataSet current = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_service_effective_get",
                new SqlParameter("@RETREAT", _retreatCode));

            if (current.Tables.Count == 0 || current.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException("저장할 식사 일정이 없습니다.");
            }

            int expectedRevision;
            if (!Int32.TryParse(hdConfigRevision.Value, out expectedRevision))
            {
                expectedRevision = Convert.ToInt32(current.Tables[0].Rows[0]["config_revision"], CultureInfo.InvariantCulture);
            }

            string xml;
            if (force && !String.IsNullOrWhiteSpace(hdPendingConfigXml.Value))
            {
                xml = hdPendingConfigXml.Value;
            }
            else
            {
                List<MealServiceOption> options = new List<MealServiceOption>();
                foreach (DataRow row in current.Tables[0].Rows)
                {
                    string date = Convert.ToString(row["meal_date"]);
                    string type = Convert.ToString(row["meal_type"]);
                    string key = "meal_config_" + date + "_" + type;
                    options.Add(new MealServiceOption
                    {
                        MealDate = date,
                        MealType = type,
                        IsProvided = String.Equals(Request.Form[key], "Y", StringComparison.Ordinal)
                    });
                }

                xml = MealPrecheckHelper.BuildConfigXml(options);
            }

            SqlParameter xmlParameter = new SqlParameter("@CONFIG_XML", SqlDbType.Xml) { Value = xml };
            DataSet result = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_service_save",
                new SqlParameter("@RETREAT", _retreatCode),
                new SqlParameter("@EXPECTED_REVISION", expectedRevision),
                xmlParameter,
                new SqlParameter("@FORCE", force ? "Y" : "N"),
                new SqlParameter("@UID", UserInfo.UserID),
                new SqlParameter("@UIP", CodeHelper.GetUserIP));

            DataRow resultRow = result.Tables[0].Rows[0];
            string resultCode = Convert.ToString(resultRow["result_code"]);
            if (resultCode == "SAVED" || resultCode == "NO_CHANGE")
            {
                Response.Redirect("/staff/mealstatus?mode=config&saved=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            BindConfig();
            if (resultCode == "CONFIRM_REQUIRED")
            {
                int affected = Convert.ToInt32(resultRow["affected_count"], CultureInfo.InvariantCulture);
                hdPendingConfigXml.Value = xml;
                hdConfigRevision.Value = expectedRevision.ToString(CultureInfo.InvariantCulture);
                pnlForceSave.Visible = true;
                lblForceMessage.Text = "기존 식사 선택 또는 직접입력 수량 합계 " + affected + "건(인분)이 삭제됩니다. 계속하려면 아래 버튼을 누르세요.";
                return;
            }

            if (resultCode == "CONFLICT")
            {
                ShowMessage("다른 사용자가 먼저 설정을 변경했습니다. 최신 내용을 다시 확인하세요.", true);
                return;
            }

            ShowMessage("식사 제공 설정을 저장하지 못했습니다.", true);
        }
        catch (Exception ex)
        {
            BindConfig();
            ShowMessage("식사 제공 설정 저장 중 오류가 발생했습니다. " + Server.HtmlEncode(ex.Message), true);
        }
    }

    private void BindDetail(int belong)
    {
        try
        {
            DataSet data = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_group_detail_get",
                new SqlParameter("@RETREAT", _retreatCode),
                new SqlParameter("@BELONG", belong));

            if (data.Tables.Count < 5 || data.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException("요회 상세 결과가 올바르지 않습니다.");
            }

            DataRow meta = data.Tables[0].Rows[0];
            lblDetailTitle.Text = Server.HtmlEncode(Convert.ToString(meta["belong_nm"])) + " 요회";
            bool isManual = String.Equals(Convert.ToString(meta["entry_mode"]), "M", StringComparison.Ordinal);
            lblDetailMeta.Text = (isManual ? "수량 직접입력 · " : String.Empty)
                + "명단 " + Convert.ToInt32(meta["member_count"], CultureInfo.InvariantCulture) + "명 · "
                + GetStatusText(Convert.ToString(meta["submission_status"]));
            lnkEditMeal.HRef = "/meal-precheck?group=" + belong.ToString(CultureInfo.InvariantCulture);
            lnkEditMeal.Attributes["aria-label"] = Convert.ToString(meta["belong_nm"]) + " 식사인원 수정";
            litDetail.Text = BuildDetailHtml(data.Tables[1], data.Tables[2], data.Tables[3], data.Tables[4]);
            pnlDetailModal.Attributes["data-meal-return-group"] = belong.ToString(CultureInfo.InvariantCulture);
            pnlDetailModal.Visible = true;
        }
        catch (Exception ex)
        {
            ShowMessage("요회 상세를 불러오지 못했습니다. " + Server.HtmlEncode(ex.Message), true);
        }
    }

    private string BuildDetailHtml(DataTable members, DataTable schedule, DataTable selections, DataTable manualCounts)
    {
        List<string> dates = new List<string>();
        Dictionary<string, List<DataRow>> providedByDate = new Dictionary<string, List<DataRow>>(StringComparer.Ordinal);
        foreach (DataRow row in schedule.Rows)
        {
            if (Convert.ToString(row["provide_yn"]) != "Y") continue;
            string date = Convert.ToString(row["meal_date"]);
            if (!providedByDate.ContainsKey(date))
            {
                providedByDate[date] = new List<DataRow>();
                dates.Add(date);
            }
            providedByDate[date].Add(row);
        }

        HashSet<string> selected = new HashSet<string>(StringComparer.Ordinal);
        foreach (DataRow row in selections.Rows)
        {
            selected.Add(Convert.ToString(row["group_member_seq"]) + "|" + Convert.ToString(row["meal_date"]) + "|" + Convert.ToString(row["meal_type"]));
        }

        Dictionary<string, int> directCounts = new Dictionary<string, int>(StringComparer.Ordinal);
        foreach (DataRow row in manualCounts.Rows)
        {
            directCounts[Convert.ToString(row["meal_date"]) + "|" + Convert.ToString(row["meal_type"])] =
                Convert.ToInt32(row["meal_count"], CultureInfo.InvariantCulture);
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class='site-meal-detail-scroll'><table class='site-meal-detail-table'><thead><tr><th>구성원</th>");
        foreach (string date in dates)
        {
            html.Append("<th>").Append(Server.HtmlEncode(MealPrecheckHelper.FormatDate(date))).Append("</th>");
        }
        html.Append("</tr></thead><tbody>");

        if (members.Rows.Count == 0)
        {
            html.Append("<tr><th scope='row'><strong>전체 대상</strong><small>수량 직접입력</small></th>");
            foreach (string date in dates)
            {
                html.Append("<td><div class='site-meal-detail-cell'>");
                foreach (DataRow meal in providedByDate[date])
                {
                    string type = Convert.ToString(meal["meal_type"]);
                    string key = date + "|" + type;
                    int count = directCounts.ContainsKey(key) ? directCounts[key] : 0;
                    html.Append("<span class='is-selected'>")
                        .Append(MealPrecheckHelper.GetMealName(type)).Append(" ")
                        .Append(count.ToString(CultureInfo.InvariantCulture)).Append("명</span>");
                }
                html.Append("</div></td>");
            }
            html.Append("</tr>");
        }

        foreach (DataRow member in members.Rows)
        {
            string memberSeq = Convert.ToString(member["group_member_seq"]);
            html.Append("<tr><th scope='row'><strong>")
                .Append(Server.HtmlEncode(Convert.ToString(member["user_nm"])))
                .Append("</strong><small>")
                .Append(Server.HtmlEncode(Convert.ToString(member["usertype_name"])))
                .Append("</small></th>");

            foreach (string date in dates)
            {
                html.Append("<td><div class='site-meal-detail-cell'>");
                foreach (DataRow meal in providedByDate[date])
                {
                    string type = Convert.ToString(meal["meal_type"]);
                    bool isSelected = selected.Contains(memberSeq + "|" + date + "|" + type);
                    html.Append("<span class='").Append(isSelected ? "is-selected" : "is-unselected").Append("'>")
                        .Append(MealPrecheckHelper.GetMealName(type)).Append(" ")
                        .Append(isSelected ? "✓" : "—").Append("</span>");
                }
                html.Append("</div></td>");
            }
            html.Append("</tr>");
        }

        html.Append("</tbody></table></div>");
        return html.ToString();
    }

    private string GetStatusText(string status)
    {
        if (status == "COMPLETED") return "제출";
        if (status == "RECHECK_REQUIRED") return "재확인 필요";
        return "미제출";
    }

    private void ShowMessage(string message, bool isError)
    {
        if (isError)
        {
            pnlMessage.Visible = false;
            pnlErrorModal.Attributes.Remove("hidden");
            lblErrorModalMessage.Text = message;
            return;
        }

        pnlMessage.Visible = true;
        pnlMessage.CssClass = "site-alert site-alert-success";
        lblMessage.Text = message;
    }
}
