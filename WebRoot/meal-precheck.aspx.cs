using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;

public partial class meal_precheck : Page
{
    private string _browserHash = String.Empty;
    private string _ipHash = String.Empty;
    private string _retreatCode = String.Empty;
    private string _loginUserId = String.Empty;
    private string _loginRole = String.Empty;
    private bool _isAuthorized;
    private bool _isLoginAuthorized;
    private bool _isGroupLocked;
    private int _lockedBelong;

    protected override void OnInit(EventArgs e)
    {
        MealPrecheckSecurity.SetPrivateNoStoreHeaders();
        if (Session != null)
        {
            // 첫 익명 요청에서도 세션 쿠키를 발급해야 다음 POST의 ViewStateUserKey가 동일하다.
            Session["MealPrecheckViewState"] = "1";
            ViewStateUserKey = Session.SessionID;
        }
        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            string browserToken = MealPrecheckSecurity.EnsureBrowserToken();
            _browserHash = MealPrecheckSecurity.GetBrowserHash(browserToken);
            _ipHash = MealPrecheckSecurity.GetIpHash(MealPrecheckSecurity.GetNormalizedClientIp());
            ResolveLoginAuthorization();
            _isAuthorized = _isLoginAuthorized || MealPrecheckSecurity.IsAuthorizedSession(_browserHash, _ipHash);
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "공개 조사 보안 설정 오류", ex);
            pnlAccess.Visible = false;
            pnlSurvey.Visible = false;
            ShowMessage("식사 조사 설정을 확인할 수 없습니다. 관리자에게 문의하세요.", true);
            return;
        }

        pnlAccess.Visible = !_isAuthorized;
        pnlSurvey.Visible = _isAuthorized;

        if (!_isAuthorized)
        {
            if (!IsPostBack)
            {
                BindAccessState();
            }
            return;
        }

        string csrfToken = MealPrecheckSecurity.EnsureCsrfToken();
        if (!IsPostBack)
        {
            hdCsrfToken.Value = csrfToken;
        }
        if (!LoadActiveRetreat())
        {
            return;
        }

        if (!IsPostBack)
        {
            BindGroups();
            BindSurvey();
            if (String.Equals(Request.QueryString["saved"], "1", StringComparison.Ordinal))
            {
                ClientScript.RegisterStartupScript(
                    GetType(),
                    "MealPrecheckSavedAlert",
                    "window.alert('저장되었습니다.');",
                    true);
            }
        }
        else if (_isGroupLocked && !ApplyLockedGroupSelection())
        {
            btnSaveSurvey.Enabled = false;
            ShowMessage("로그인한 요회목자의 소속 요회를 현재 수양회에서 찾을 수 없습니다. 관리자에게 문의하세요.", true);
        }
    }

    protected void btnAccess_Click(object sender, EventArgs e)
    {
        if (_isLoginAuthorized)
        {
            Response.Redirect("/meal-precheck", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        try
        {
            MealAccessGuardState guard = MealPrecheckSecurity.GetGuardState(_browserHash, _ipHash);
            if (guard.IsLocked)
            {
                ShowLockedState(guard);
                return;
            }

            if (!MealPrecheckSecurity.VerifyPassword(txtAccessPassword.Text))
            {
                guard = MealPrecheckSecurity.RecordFailure(_browserHash, _ipHash);
                if (guard.IsLocked)
                {
                    ShowLockedState(guard);
                }
                else
                {
                    lblAccessState.Text = "암호가 올바르지 않습니다. 남은 시도: " + guard.RemainingAttempts + "회";
                    ShowMessage(lblAccessState.Text, true);
                }
                txtAccessPassword.Text = String.Empty;
                return;
            }

            guard = MealPrecheckSecurity.TryCompleteAuthorization(_browserHash, _ipHash);
            if (guard.IsLocked)
            {
                ShowLockedState(guard);
                return;
            }

            MealPrecheckSecurity.CreateAuthorizedSession(_browserHash, _ipHash);
            Response.Redirect("/meal-precheck", false);
            Context.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "공개 조사 인증 오류", ex);
            ShowMessage("암호를 확인하는 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.", true);
        }
    }

    protected void ddlGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!EnsureAuthorizedRequest())
        {
            return;
        }

        hdRetreat.Value = _retreatCode;
        BindSurvey();
    }

    protected void btnSaveSurvey_Click(object sender, EventArgs e)
    {
        if (!EnsureAuthorizedRequest())
        {
            return;
        }

        if (!ValidateMutationCsrf())
        {
            return;
        }

        if (!String.Equals(hdRetreat.Value, _retreatCode, StringComparison.Ordinal))
        {
            BindGroups();
            BindSurvey();
            ShowMessage("사용 중인 수양회가 변경되어 저장하지 않았습니다. 새 내용을 확인하세요.", true);
            return;
        }

        int belong;
        if (!TryGetSelectedBelong(out belong))
        {
            ShowMessage("요회 정보가 올바르지 않습니다.", true);
            return;
        }

        try
        {
            DataSet current = LoadSurveyData(belong);
            if (current.Tables.Count < 4)
            {
                throw new InvalidOperationException("조사 자료가 올바르지 않습니다.");
            }

            HashSet<int> members = new HashSet<int>();
            foreach (DataRow member in current.Tables[1].Rows)
            {
                members.Add(Convert.ToInt32(member["group_member_seq"], CultureInfo.InvariantCulture));
            }

            List<string> providedMeals = new List<string>();
            foreach (DataRow meal in current.Tables[2].Rows)
            {
                if (Convert.ToString(meal["provide_yn"]) == "Y")
                {
                    providedMeals.Add(Convert.ToString(meal["meal_date"]) + "|" + Convert.ToString(meal["meal_type"]));
                }
            }

            List<MealSelectionItem> selections = new List<MealSelectionItem>();
            foreach (int memberSeq in members)
            {
                foreach (string providedMeal in providedMeals)
                {
                    string[] parts = providedMeal.Split('|');
                    string key = "meal_" + memberSeq.ToString(CultureInfo.InvariantCulture) + "_" + parts[0] + "_" + parts[1];
                    if (String.Equals(Request.Form[key], "Y", StringComparison.Ordinal))
                    {
                        selections.Add(new MealSelectionItem
                        {
                            GroupMemberSeq = memberSeq,
                            MealDate = parts[0],
                            MealType = parts[1]
                        });
                    }
                }
            }

            int expectedRevision;
            if (!Int32.TryParse(hdSubmissionRevision.Value, out expectedRevision))
            {
                expectedRevision = Convert.ToInt32(current.Tables[0].Rows[0]["submission_revision"], CultureInfo.InvariantCulture);
            }

            string xml = MealPrecheckHelper.BuildSelectionXml(selections);
            SqlParameter xmlParameter = new SqlParameter("@SELECTION_XML", SqlDbType.Xml) { Value = xml };
            DataSet result = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_survey_save",
                new SqlParameter("@RETREAT", _retreatCode),
                new SqlParameter("@BELONG", belong),
                new SqlParameter("@EXPECTED_REVISION", expectedRevision),
                xmlParameter,
                new SqlParameter("@BROWSER_KEY_HASH", _browserHash),
                new SqlParameter("@IP_HASH", _ipHash),
                new SqlParameter("@UID", _isLoginAuthorized ? _loginUserId : "meal-precheck"),
                new SqlParameter("@UIP", "public-survey"));

            DataRow resultRow = result.Tables[0].Rows[0];
            string resultCode = Convert.ToString(resultRow["result_code"]);
            if (resultCode == "SAVED")
            {
                Response.Redirect("/meal-precheck?group=" + belong.ToString(CultureInfo.InvariantCulture) + "&saved=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            BindSurvey();
            if (resultCode == "CONFLICT")
            {
                ShowMessage("다른 사용자가 먼저 저장했습니다. 최신 내용을 확인한 후 다시 저장하세요.", true);
                return;
            }

            ShowMessage("식사 여부를 저장하지 못했습니다.", true);
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "공개 조사 저장 오류", ex);
            BindSurvey();
            ShowMessage("식사 여부 저장 중 오류가 발생했습니다. 최신 내용을 확인한 후 다시 시도하세요.", true);
        }
    }

    protected void btnAddMember_Click(object sender, EventArgs e)
    {
        if (!EnsureAuthorizedRequest() || !ValidateMutationCsrf())
        {
            return;
        }

        int belong;
        if (!TryGetSelectedBelong(out belong))
        {
            ShowAddMemberError("요회 정보가 올바르지 않습니다.");
            return;
        }

        string memberName = (txtNewMemberName.Text ?? String.Empty).Trim();
        int userType;
        if (String.IsNullOrWhiteSpace(memberName) || memberName.Length > 100 || !IsValidMemberName(memberName))
        {
            ShowAddMemberError("성명은 100자 이내의 한글·영문·숫자·공백·하이픈·마침표만 입력할 수 있습니다.");
            return;
        }
        if (!Int32.TryParse(ddlNewMemberType.SelectedValue, out userType) || userType < 1 || userType > 3)
        {
            ShowAddMemberError("회원구분이 올바르지 않습니다.");
            return;
        }

        string category = ddlNewMemberCategory.SelectedValue;
        if (category != "graduate" && category != "student")
        {
            ShowAddMemberError("학사/학생 구분이 올바르지 않습니다.");
            return;
        }

        try
        {
            DataSet groupData = LoadSurveyData(belong);
            if (groupData.Tables.Count < 4 || groupData.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException("활성 요회 정보를 찾을 수 없습니다.");
            }

            int duesType = GetDuesType(category);
            DataSet result = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_group_member_save",
                new SqlParameter("@SEQ", DBNull.Value),
                new SqlParameter("@USER_NM", memberName),
                new SqlParameter("@BELONG", belong),
                new SqlParameter("@RETREAT", _retreatCode),
                new SqlParameter("@USERTYPE", userType),
                new SqlParameter("@DUESTYPE", duesType),
                new SqlParameter("@USER_DUES", SqlDbType.Int) { Value = 0 },
                new SqlParameter("@HOWTO_REGIST", 1),
                new SqlParameter("@USER_DESC", String.Empty),
                new SqlParameter("@MANAGER_CONFIRM", "N"),
                new SqlParameter("@ATTEND", "N"),
                new SqlParameter("@UID", _isLoginAuthorized ? _loginUserId : "meal-precheck"),
                new SqlParameter("@UIP", CodeHelper.GetUserIP),
                new SqlParameter("@AUTH", _isLoginAuthorized ? _loginRole : "anonymous"));

            if (result.Tables.Count == 0 || result.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException("신규인원 식별값을 확인할 수 없습니다.");
            }

            int newMemberSeq;
            if (!Int32.TryParse(Convert.ToString(result.Tables[0].Rows[0]["new_seq"], CultureInfo.InvariantCulture), out newMemberSeq)
                || newMemberSeq <= 0)
            {
                throw new InvalidOperationException("신규인원 저장 결과가 올바르지 않습니다.");
            }

            Response.Redirect(
                "/meal-precheck?group=" + belong.ToString(CultureInfo.InvariantCulture)
                + "&added=1&member=" + newMemberSeq.ToString(CultureInfo.InvariantCulture),
                false);
            Context.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "신규인원 추가 오류", ex);
            ShowAddMemberError("신규인원을 추가하지 못했습니다. " + Server.HtmlEncode(ex.Message));
        }
    }

    private bool EnsureAuthorizedRequest()
    {
        if (_isLoginAuthorized)
        {
            return true;
        }

        if (!MealPrecheckSecurity.IsAuthorizedSession(_browserHash, _ipHash))
        {
            pnlAccess.Visible = true;
            pnlSurvey.Visible = false;
            ShowMessage("인증 시간이 만료되었습니다. 암호를 다시 입력하세요.", true);
            return false;
        }

        return true;
    }

    private bool ValidateMutationCsrf()
    {
        if (MealPrecheckSecurity.ValidateCsrfToken(hdCsrfToken.Value))
        {
            return true;
        }

        if (_isLoginAuthorized)
        {
            ShowMessage("요청 확인값이 만료되었습니다. 페이지를 새로고침한 후 다시 시도하세요.", true);
            pnlAccess.Visible = false;
            pnlSurvey.Visible = true;
        }
        else
        {
            MealPrecheckSecurity.ClearAuthorizedSession();
            ShowMessage("요청 확인값이 만료되었습니다. 암호를 다시 입력하세요.", true);
            pnlAccess.Visible = true;
            pnlSurvey.Visible = false;
        }

        return false;
    }

    private void ResolveLoginAuthorization()
    {
        _loginUserId = (UserInfo.UserID ?? String.Empty).Trim();
        _loginRole = (UserInfo.UserRole ?? String.Empty).Trim().ToLowerInvariant();

        bool hasLogin = !String.IsNullOrWhiteSpace(_loginUserId)
            && !String.Equals(_loginUserId, "anonymous", StringComparison.OrdinalIgnoreCase);
        _isLoginAuthorized = hasLogin
            && (_loginRole == "user" || _loginRole == "manager" || _loginRole == "admin");

        _isGroupLocked = _isLoginAuthorized && _loginRole == "user";
        if (_isGroupLocked)
        {
            if (!Int32.TryParse(UserInfo.LoginUserBelongCode, out _lockedBelong) || _lockedBelong <= 0)
            {
                _lockedBelong = 0;
            }
        }
    }

    private void BindAccessState()
    {
        try
        {
            MealAccessGuardState guard = MealPrecheckSecurity.GetGuardState(_browserHash, _ipHash);
            if (guard.IsLocked)
            {
                ShowLockedState(guard);
            }
            else if (guard.FailedCount > 0)
            {
                lblAccessState.Text = "남은 시도: " + guard.RemainingAttempts + "회";
            }
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "접근 제한 조회 오류", ex);
            ShowMessage("접근 상태를 확인하지 못했습니다. 잠시 후 다시 시도하세요.", true);
        }
    }

    private void ShowLockedState(MealAccessGuardState guard)
    {
        btnAccess.Enabled = false;
        txtAccessPassword.Enabled = false;
        if (guard.LockedUntilUtc.HasValue)
        {
            DateTime local = guard.LockedUntilUtc.Value.ToLocalTime();
            lblAccessState.Text = "현재 재시도할 수 없습니다. " + local.ToString("HH:mm:ss", CultureInfo.InvariantCulture) + " 이후 다시 시도하세요.";
        }
        else
        {
            lblAccessState.Text = "현재 재시도할 수 없습니다. 잠시 후 다시 시도하세요.";
        }
        ShowMessage(lblAccessState.Text, true);
    }

    private bool LoadActiveRetreat()
    {
        try
        {
            DataSet data = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_get");
            if (data.Tables.Count == 0 || data.Tables[0].Rows.Count == 0)
            {
                btnSaveSurvey.Enabled = false;
                btnOpenAddMember.Disabled = true;
                ShowMessage("현재 사용 중인 수양회가 없습니다. 실무자에게 문의하세요.", true);
                return false;
            }

            ddlRetreat.DataSource = data.Tables[0];
            ddlRetreat.DataBind();
            ddlRetreat.Enabled = false;
            ddlRetreat.Attributes["aria-disabled"] = "true";
            _retreatCode = Convert.ToString(data.Tables[0].Rows[0]["seq"], CultureInfo.InvariantCulture);
            if (!IsPostBack)
            {
                hdRetreat.Value = _retreatCode;
            }
            return true;
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "활성 수양회 조회 오류", ex);
            btnOpenAddMember.Disabled = true;
            ShowMessage("수양회 정보를 확인하지 못했습니다. 실무자에게 문의하세요.", true);
            return false;
        }
    }

    private void BindGroups()
    {
        DataSet data = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_survey_groups_get",
            new SqlParameter("@RETREAT", _retreatCode));

        ddlGroup.DataSource = data.Tables[0];
        ddlGroup.DataBind();
        hdRetreat.Value = _retreatCode;

        if (_isGroupLocked)
        {
            if (!ApplyLockedGroupSelection())
            {
                ddlGroup.Enabled = false;
                btnSaveSurvey.Enabled = false;
                btnOpenAddMember.Disabled = true;
                litSurvey.Text = "<div class='site-empty-state'>로그인한 소속 요회를 현재 수양회에서 찾을 수 없습니다.</div>";
                lblGroupTitle.Text = String.Empty;
                ShowMessage("로그인한 요회목자의 소속 요회를 현재 수양회에서 찾을 수 없습니다. 관리자에게 문의하세요.", true);
                return;
            }
        }
        else
        {
            int requestedGroup;
            if (Int32.TryParse(Request.QueryString["group"], out requestedGroup)
                && ddlGroup.Items.FindByValue(requestedGroup.ToString(CultureInfo.InvariantCulture)) != null)
            {
                ddlGroup.SelectedValue = requestedGroup.ToString(CultureInfo.InvariantCulture);
            }
        }

        bool hasGroups = ddlGroup.Items.Count > 0;
        ddlGroup.Enabled = hasGroups && !_isGroupLocked;
        if (_isGroupLocked)
        {
            ddlGroup.Attributes["aria-disabled"] = "true";
            ddlGroup.ToolTip = "요회목자는 로그인한 소속 요회만 조사할 수 있습니다.";
        }
        btnSaveSurvey.Enabled = hasGroups;
        btnOpenAddMember.Disabled = !hasGroups;
        if (!hasGroups)
        {
            litSurvey.Text = "<div class='site-empty-state'>조사할 요회가 없습니다.</div>";
            lblGroupTitle.Text = String.Empty;
        }
    }

    private void BindSurvey()
    {
        int belong;
        if (!TryGetSelectedBelong(out belong))
        {
            btnSaveSurvey.Enabled = false;
            return;
        }

        try
        {
            DataSet data = LoadSurveyData(belong);
            if (data.Tables.Count < 4 || data.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException("조사 자료가 올바르지 않습니다.");
            }

            DataRow meta = data.Tables[0].Rows[0];
            lblGroupTitle.Text = Server.HtmlEncode(Convert.ToString(meta["belong_nm"])) + " 식사 조사";
            hdSubmissionRevision.Value = Convert.ToString(meta["submission_revision"], CultureInfo.InvariantCulture);
            lblSubmissionState.Text = BuildSubmissionState(meta);
            litSurvey.Text = BuildSurveyHtml(data.Tables[1], data.Tables[2], data.Tables[3]);
            btnSaveSurvey.Enabled = data.Tables[1].Rows.Count > 0 && data.Tables[2].Select("provide_yn = 'Y'").Length > 0;
        }
        catch (Exception ex)
        {
            Trace.Warn("MealPrecheck", "조사 화면 조회 오류", ex);
            litSurvey.Text = "<div class='site-empty-state'>조사 내용을 불러오지 못했습니다.</div>";
            btnSaveSurvey.Enabled = false;
            ShowMessage("조사 내용을 불러오지 못했습니다. 잠시 후 다시 시도하세요.", true);
        }
    }

    private DataSet LoadSurveyData(int belong)
    {
        return EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_survey_members_get",
            new SqlParameter("@RETREAT", _retreatCode),
            new SqlParameter("@BELONG", belong));
    }

    private int GetDuesType(string category)
    {
        string duesName = category == "graduate" ? "학사" : "학생";
        DataSet data = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_retreatdues_get_list",
            new SqlParameter("@RETREAT", _retreatCode),
            new SqlParameter("@SORT_DIRECTION", "ASC"));

        int duesType = 0;
        int matchCount = 0;
        if (data.Tables.Count > 0)
        {
            foreach (DataRow row in data.Tables[0].Rows)
            {
                if (String.Equals(Convert.ToString(row["dues_nm"]).Trim(), duesName, StringComparison.Ordinal))
                {
                    duesType = Convert.ToInt32(row["seq"], CultureInfo.InvariantCulture);
                    matchCount++;
                }
            }
        }

        if (matchCount != 1 || duesType <= 0)
        {
            throw new InvalidOperationException("현재 수양회의 " + duesName + " 회비구분을 정확히 한 건 찾을 수 없습니다.");
        }

        return duesType;
    }

    private bool IsValidMemberName(string value)
    {
        foreach (char character in value)
        {
            if (!Char.IsLetterOrDigit(character)
                && !Char.IsWhiteSpace(character)
                && character != '-'
                && character != '.'
                && character != '·'
                && character != 'ㆍ')
            {
                return false;
            }
        }
        return true;
    }

    private void ShowAddMemberError(string message)
    {
        ShowMessage(message, true);
        pnlAddMemberModal.Attributes.Remove("hidden");
    }

    private bool ApplyLockedGroupSelection()
    {
        if (!_isGroupLocked)
        {
            return true;
        }

        string value = _lockedBelong.ToString(CultureInfo.InvariantCulture);
        if (ddlGroup.Items.FindByValue(value) == null)
        {
            return false;
        }

        ddlGroup.SelectedValue = value;
        ddlGroup.Enabled = false;
        ddlGroup.Attributes["aria-disabled"] = "true";
        return true;
    }

    private bool TryGetSelectedBelong(out int belong)
    {
        if (_isGroupLocked)
        {
            belong = _lockedBelong;
            return ApplyLockedGroupSelection();
        }

        return Int32.TryParse(ddlGroup.SelectedValue, out belong) && belong > 0;
    }

    private string BuildSubmissionState(DataRow meta)
    {
        string status = Convert.ToString(meta["submission_status"]);
        string text = status == "COMPLETED" ? "제출완료" : status == "RECHECK_REQUIRED" ? "재확인 필요" : "미제출";
        if (!meta.IsNull("submitted_dt"))
        {
            DateTime submitted = DateTime.SpecifyKind(Convert.ToDateTime(meta["submitted_dt"], CultureInfo.InvariantCulture), DateTimeKind.Utc).ToLocalTime();
            text += " · 마지막 저장 " + submitted.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture);
        }
        return Server.HtmlEncode(text);
    }

    private string BuildSurveyHtml(DataTable members, DataTable schedule, DataTable selections)
    {
        if (members.Rows.Count == 0)
        {
            return "<div class='site-empty-state'>등록된 구성원이 없습니다.</div>";
        }

        List<string> dates = new List<string>();
        Dictionary<string, List<string>> mealsByDate = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        foreach (DataRow row in schedule.Rows)
        {
            if (Convert.ToString(row["provide_yn"]) != "Y") continue;
            string date = Convert.ToString(row["meal_date"]);
            if (!mealsByDate.ContainsKey(date))
            {
                mealsByDate[date] = new List<string>();
                dates.Add(date);
            }
            mealsByDate[date].Add(Convert.ToString(row["meal_type"]));
        }

        if (dates.Count == 0)
        {
            return "<div class='site-empty-state'>조사할 식사가 없습니다. 실무자에게 문의하세요.</div>";
        }

        HashSet<string> selected = new HashSet<string>(StringComparer.Ordinal);
        foreach (DataRow row in selections.Rows)
        {
            selected.Add(Convert.ToString(row["group_member_seq"]) + "|" + Convert.ToString(row["meal_date"]) + "|" + Convert.ToString(row["meal_type"]));
        }

        int addedMemberSeq = 0;
        bool hasAddedMember = String.Equals(Request.QueryString["added"], "1", StringComparison.Ordinal)
            && Int32.TryParse(Request.QueryString["member"], out addedMemberSeq)
            && addedMemberSeq > 0;

        StringBuilder html = new StringBuilder();
        html.Append("<div class='site-meal-survey-table-wrap'><table class='site-meal-survey-table'><thead><tr><th>구성원</th>");
        foreach (string date in dates)
        {
            html.Append("<th scope='col' aria-label='").Append(Server.HtmlEncode(MealPrecheckHelper.FormatDateLong(date))).Append("'>")
                .Append(Server.HtmlEncode(MealPrecheckHelper.FormatDate(date))).Append("</th>");
        }
        html.Append("</tr></thead><tbody>");

        foreach (DataRow member in members.Rows)
        {
            int memberSeq = Convert.ToInt32(member["group_member_seq"], CultureInfo.InvariantCulture);
            string memberName = Server.HtmlEncode(Convert.ToString(member["user_nm"]));
            string userType = Server.HtmlEncode(Convert.ToString(member["usertype_name"]));
            bool isAddedMember = hasAddedMember && memberSeq == addedMemberSeq;
            html.Append("<tr id='mealMember_").Append(memberSeq.ToString(CultureInfo.InvariantCulture))
                .Append("' class='site-meal-member-card")
                .Append(isAddedMember ? " is-new-member' data-meal-new-member='true' tabindex='-1'" : "'")
                .Append("><th scope='row'><div class='site-meal-member-heading'><strong>").Append(memberName)
                .Append("</strong><button type='button' class='site-meal-member-toggle' data-meal-member-toggle aria-pressed='false'>전체선택</button></div><small>")
                .Append(userType).Append("</small></th>");

            foreach (string date in dates)
            {
                html.Append("<td data-date-label='").Append(Server.HtmlEncode(MealPrecheckHelper.FormatDate(date))).Append("'><div class='site-meal-cell-options'>");
                foreach (string type in mealsByDate[date])
                {
                    string key = memberSeq.ToString(CultureInfo.InvariantCulture) + "|" + date + "|" + type;
                    string name = "meal_" + memberSeq.ToString(CultureInfo.InvariantCulture) + "_" + date + "_" + type;
                    string id = "mealCheck_" + memberSeq.ToString(CultureInfo.InvariantCulture) + "_" + date + "_" + type;
                    html.Append("<label class='site-meal-choice' for='").Append(id).Append("'><input type='checkbox' id='")
                        .Append(id).Append("' name='").Append(name).Append("' value='Y' data-meal-survey-checkbox='true'")
                        .Append(selected.Contains(key) ? " checked='checked'" : String.Empty)
                        .Append(" /><span>").Append(MealPrecheckHelper.GetMealName(type)).Append("</span></label>");
                }
                html.Append("</div></td>");
            }
            html.Append("</tr>");
        }

        html.Append("</tbody></table></div>");
        return html.ToString();
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
