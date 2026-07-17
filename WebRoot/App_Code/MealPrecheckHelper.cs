using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Xml;

public sealed class MealServiceOption
{
    public string MealDate { get; set; }
    public string MealType { get; set; }
    public bool IsProvided { get; set; }
}

public sealed class MealSelectionItem
{
    public int GroupMemberSeq { get; set; }
    public string MealDate { get; set; }
    public string MealType { get; set; }
}

public static class MealPrecheckHelper
{
    private const string DateFormat = "yyyyMMdd";

    public static DateTime ParseDate(string value, string fieldName)
    {
        DateTime result;
        if (!DateTime.TryParseExact(
            value,
            DateFormat,
            CultureInfo.InvariantCulture,
            DateTimeStyles.None,
            out result))
        {
            throw new InvalidOperationException(fieldName + " 날짜가 올바르지 않습니다.");
        }

        return result.Date;
    }

    public static IList<DateTime> GetRetreatDates(string startValue, string endValue, int maxDays)
    {
        DateTime startDate = ParseDate(startValue, "수양회 시작일");
        DateTime endDate = ParseDate(endValue, "수양회 종료일");

        if (startDate > endDate)
        {
            throw new InvalidOperationException("수양회 시작일이 종료일보다 늦습니다.");
        }

        int dayCount = (endDate - startDate).Days + 1;
        if (dayCount > maxDays)
        {
            throw new InvalidOperationException("수양회 기간이 식사 조사 허용 범위를 초과했습니다.");
        }

        List<DateTime> dates = new List<DateTime>(dayCount);
        for (DateTime date = startDate; date <= endDate; date = date.AddDays(1))
        {
            dates.Add(date);
        }

        return dates;
    }

    public static bool IsDefaultProvided(DateTime date, DateTime startDate, DateTime endDate, string mealType)
    {
        ValidateMealType(mealType);

        if (startDate.Date == endDate.Date)
        {
            return true;
        }

        if (date.Date == startDate.Date)
        {
            return mealType == "D";
        }

        if (date.Date == endDate.Date)
        {
            return mealType == "B" || mealType == "L";
        }

        return date.Date > startDate.Date && date.Date < endDate.Date;
    }

    public static string GetMealName(string mealType)
    {
        switch (mealType)
        {
            case "B": return "아침";
            case "L": return "점심";
            case "D": return "저녁";
            default: throw new InvalidOperationException("식사 코드가 올바르지 않습니다.");
        }
    }

    public static int GetMealOrder(string mealType)
    {
        switch (mealType)
        {
            case "B": return 1;
            case "L": return 2;
            case "D": return 3;
            default: throw new InvalidOperationException("식사 코드가 올바르지 않습니다.");
        }
    }

    public static void ValidateMealType(string mealType)
    {
        GetMealOrder(mealType);
    }

    public static string ToDateKey(DateTime date)
    {
        return date.ToString(DateFormat, CultureInfo.InvariantCulture);
    }

    public static string FormatDate(string dateValue)
    {
        return ParseDate(dateValue, "식사일").ToString("MM/dd(ddd)", CultureInfo.GetCultureInfo("ko-KR"));
    }

    public static string FormatDateLong(string dateValue)
    {
        return ParseDate(dateValue, "식사일").ToString("yyyy년 M월 d일 dddd", CultureInfo.GetCultureInfo("ko-KR"));
    }

    public static string BuildConfigXml(IEnumerable<MealServiceOption> options)
    {
        StringBuilder builder = new StringBuilder();
        XmlWriterSettings settings = new XmlWriterSettings
        {
            OmitXmlDeclaration = true,
            ConformanceLevel = ConformanceLevel.Document
        };

        using (XmlWriter writer = XmlWriter.Create(new StringWriter(builder, CultureInfo.InvariantCulture), settings))
        {
            writer.WriteStartElement("config");
            foreach (MealServiceOption option in options)
            {
                ParseDate(option.MealDate, "식사일");
                ValidateMealType(option.MealType);

                writer.WriteStartElement("item");
                writer.WriteAttributeString("date", option.MealDate);
                writer.WriteAttributeString("type", option.MealType);
                writer.WriteAttributeString("provided", option.IsProvided ? "Y" : "N");
                writer.WriteEndElement();
            }
            writer.WriteEndElement();
        }

        return builder.ToString();
    }

    public static string BuildSelectionXml(IEnumerable<MealSelectionItem> selections)
    {
        StringBuilder builder = new StringBuilder();
        XmlWriterSettings settings = new XmlWriterSettings
        {
            OmitXmlDeclaration = true,
            ConformanceLevel = ConformanceLevel.Document
        };

        using (XmlWriter writer = XmlWriter.Create(new StringWriter(builder, CultureInfo.InvariantCulture), settings))
        {
            writer.WriteStartElement("selections");
            foreach (MealSelectionItem selection in selections)
            {
                if (selection.GroupMemberSeq <= 0)
                {
                    throw new InvalidOperationException("구성원 식별값이 올바르지 않습니다.");
                }

                ParseDate(selection.MealDate, "식사일");
                ValidateMealType(selection.MealType);

                writer.WriteStartElement("item");
                writer.WriteAttributeString("member", selection.GroupMemberSeq.ToString(CultureInfo.InvariantCulture));
                writer.WriteAttributeString("date", selection.MealDate);
                writer.WriteAttributeString("type", selection.MealType);
                writer.WriteEndElement();
            }
            writer.WriteEndElement();
        }

        return builder.ToString();
    }
}
