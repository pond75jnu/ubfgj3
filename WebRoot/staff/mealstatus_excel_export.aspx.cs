using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Threading;
using System.Web;
using System.Web.UI;

public partial class staff_mealstatus_excel_export : Page
{
    private sealed class GroupExportData
    {
        public string GroupName { get; set; }
        public DataSet Detail { get; set; }
    }

    private sealed class MealColumn
    {
        public string MealDate { get; set; }
        public string MealType { get; set; }
        public string Header { get; set; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!CanManageMeals())
        {
            Response.Redirect("/", false);
            Context.ApplicationInstance.CompleteRequest();
            return;
        }

        if (IsPostBack)
        {
            return;
        }

        try
        {
            ExportExcel();
        }
        catch (ThreadAbortException)
        {
            // XlsxExportHelper의 Response.End가 다운로드 응답을 종료할 때 발생한다.
        }
        catch (Exception ex)
        {
            WriteError("식사 선택 상세 엑셀을 생성하지 못했습니다. " + ex.Message);
        }
    }

    private bool CanManageMeals()
    {
        string role = (UserInfo.UserRole ?? String.Empty).Trim().ToLowerInvariant();
        return role == "manager" || role == "admin";
    }

    private void ExportExcel()
    {
        DataSet retreatData = EfStoredProcedure.ExecuteDataSet("ubfgj3.dbo.SP_retreat_active_get");
        if (retreatData.Tables.Count == 0 || retreatData.Tables[0].Rows.Count == 0)
        {
            throw new InvalidOperationException("현재 사용 중인 수양회가 없습니다.");
        }

        DataRow retreat = retreatData.Tables[0].Rows[0];
        int retreatCode = Convert.ToInt32(retreat["seq"], CultureInfo.InvariantCulture);
        string retreatName = Convert.ToString(retreat["retreat_name"], CultureInfo.InvariantCulture);

        DataSet groupData = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_survey_groups_get",
            new SqlParameter("@RETREAT", retreatCode));

        if (groupData.Tables.Count == 0)
        {
            throw new InvalidOperationException("요회 목록 결과가 올바르지 않습니다.");
        }

        List<GroupExportData> groups = LoadGroupDetails(retreatCode, groupData.Tables[0]);
        List<MealColumn> mealColumns = BuildMealColumns(groups);
        DataTable exportTable = BuildExportTable(groups, mealColumns);

        string fileName = MakeSafeFileName(retreatName)
            + "_식사선택상세_"
            + DateTime.Now.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture)
            + ".xlsx";

        XlsxExportHelper.WriteDataTableToResponse(Response, exportTable, fileName, "식사선택상세", true);
    }

    private static List<GroupExportData> LoadGroupDetails(int retreatCode, DataTable groupTable)
    {
        List<GroupExportData> groups = new List<GroupExportData>();
        foreach (DataRow group in groupTable.Rows)
        {
            int belong = Convert.ToInt32(group["seq"], CultureInfo.InvariantCulture);
            DataSet detail = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_meal_group_detail_get",
                new SqlParameter("@RETREAT", retreatCode),
                new SqlParameter("@BELONG", belong));

            if (detail.Tables.Count < 4 || detail.Tables[0].Rows.Count == 0)
            {
                throw new InvalidOperationException(Convert.ToString(group["belong_nm"]) + " 상세 결과가 올바르지 않습니다.");
            }

            groups.Add(new GroupExportData
            {
                GroupName = Convert.ToString(group["belong_nm"], CultureInfo.InvariantCulture),
                Detail = detail
            });
        }
        return groups;
    }

    private static List<MealColumn> BuildMealColumns(IList<GroupExportData> groups)
    {
        List<MealColumn> columns = new List<MealColumn>();
        if (groups.Count == 0)
        {
            return columns;
        }

        DataTable schedule = groups[0].Detail.Tables[2];
        foreach (DataRow meal in schedule.Rows)
        {
            if (!String.Equals(Convert.ToString(meal["provide_yn"]), "Y", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            string mealDate = Convert.ToString(meal["meal_date"], CultureInfo.InvariantCulture);
            string mealType = Convert.ToString(meal["meal_type"], CultureInfo.InvariantCulture);
            string mealName = Convert.ToString(meal["meal_name"], CultureInfo.InvariantCulture);
            columns.Add(new MealColumn
            {
                MealDate = mealDate,
                MealType = mealType,
                Header = MealPrecheckHelper.FormatDate(mealDate) + " " + mealName
            });
        }
        return columns;
    }

    private static DataTable BuildExportTable(IList<GroupExportData> groups, IList<MealColumn> mealColumns)
    {
        DataTable table = new DataTable("식사선택상세");
        table.Locale = CultureInfo.GetCultureInfo("ko-KR");
        table.Columns.Add("요회", typeof(string));
        table.Columns.Add("제출상태", typeof(string));
        table.Columns.Add("성명", typeof(string));
        table.Columns.Add("회원구분", typeof(string));
        foreach (MealColumn meal in mealColumns)
        {
            table.Columns.Add(meal.Header, typeof(int));
        }
        table.Columns.Add("선택합계", typeof(int));

        foreach (GroupExportData group in groups)
        {
            DataRow meta = group.Detail.Tables[0].Rows[0];
            DataTable members = group.Detail.Tables[1];
            HashSet<string> selections = BuildSelectionSet(group.Detail.Tables[3]);
            string status = GetStatusText(Convert.ToString(meta["submission_status"]));

            if (members.Rows.Count == 0)
            {
                DataRow emptyRow = table.NewRow();
                emptyRow["요회"] = group.GroupName;
                emptyRow["제출상태"] = status;
                emptyRow["성명"] = "(구성원 없음)";
                emptyRow["회원구분"] = String.Empty;
                foreach (MealColumn meal in mealColumns)
                {
                    emptyRow[meal.Header] = 0;
                }
                emptyRow["선택합계"] = 0;
                table.Rows.Add(emptyRow);
                continue;
            }

            foreach (DataRow member in members.Rows)
            {
                string memberSeq = Convert.ToString(member["group_member_seq"], CultureInfo.InvariantCulture);
                DataRow row = table.NewRow();
                row["요회"] = group.GroupName;
                row["제출상태"] = status;
                row["성명"] = Convert.ToString(member["user_nm"], CultureInfo.InvariantCulture);
                row["회원구분"] = Convert.ToString(member["usertype_name"], CultureInfo.InvariantCulture);

                int selectionCount = 0;
                foreach (MealColumn meal in mealColumns)
                {
                    bool isSelected = selections.Contains(memberSeq + "|" + meal.MealDate + "|" + meal.MealType);
                    row[meal.Header] = isSelected ? 1 : 0;
                    if (isSelected)
                    {
                        selectionCount++;
                    }
                }
                row["선택합계"] = selectionCount;
                table.Rows.Add(row);
            }
        }

        return table;
    }

    private static HashSet<string> BuildSelectionSet(DataTable selectionTable)
    {
        HashSet<string> selections = new HashSet<string>(StringComparer.Ordinal);
        foreach (DataRow selection in selectionTable.Rows)
        {
            selections.Add(
                Convert.ToString(selection["group_member_seq"], CultureInfo.InvariantCulture)
                + "|"
                + Convert.ToString(selection["meal_date"], CultureInfo.InvariantCulture)
                + "|"
                + Convert.ToString(selection["meal_type"], CultureInfo.InvariantCulture));
        }
        return selections;
    }

    private static string GetStatusText(string status)
    {
        if (String.Equals(status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
        {
            return "제출";
        }
        if (String.Equals(status, "RECHECK_REQUIRED", StringComparison.OrdinalIgnoreCase))
        {
            return "재확인 필요";
        }
        return "미제출";
    }

    private static string MakeSafeFileName(string value)
    {
        string result = String.IsNullOrWhiteSpace(value) ? "수양회" : value.Trim();
        foreach (char invalidCharacter in Path.GetInvalidFileNameChars())
        {
            result = result.Replace(invalidCharacter, '_');
        }
        return result;
    }

    private void WriteError(string message)
    {
        Response.Clear();
        Response.StatusCode = 500;
        Response.TrySkipIisCustomErrors = true;
        Response.ContentType = "text/html; charset=utf-8";
        Response.Write("<!doctype html><html lang='ko'><head><meta charset='utf-8'><title>엑셀 다운로드 오류</title></head><body>");
        Response.Write("<p>" + HttpUtility.HtmlEncode(message) + "</p>");
        Response.Write("<p><a href='/staff/mealstatus'>식사수량 현황으로 돌아가기</a></p></body></html>");
        Context.ApplicationInstance.CompleteRequest();
    }
}
