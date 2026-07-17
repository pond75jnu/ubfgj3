using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Net;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Web;

public sealed class MealAccessGuardState
{
    public bool IsLocked { get; set; }
    public DateTime? LockedUntilUtc { get; set; }
    public int FailedCount { get; set; }
    public int RemainingAttempts { get; set; }
}

public static class MealPrecheckSecurity
{
    private const string BrowserCookieName = "MealPrecheckBrowser";
    private const string AuthorizedKey = "MealPrecheckAuthorized";
    private const string AuthorizedAtKey = "MealPrecheckAuthorizedAtUtc";
    private const string AuthorizedIpKey = "MealPrecheckAuthorizedIpHash";
    private const string AuthorizedBrowserKey = "MealPrecheckAuthorizedBrowserHash";
    private const string CsrfKey = "MealPrecheckCsrfToken";

    public static string EnsureBrowserToken()
    {
        HttpContext context = HttpContext.Current;
        HttpCookie existing = context.Request.Cookies[BrowserCookieName];
        if (existing != null && IsValidBrowserToken(existing.Value))
        {
            return existing.Value;
        }

        string token = CreateRandomToken(32);
        HttpCookie cookie = new HttpCookie(BrowserCookieName, token)
        {
            HttpOnly = true,
            Secure = context.Request.IsSecureConnection,
            Path = "/"
        };

        SetSameSiteLax(cookie);
        context.Response.Cookies.Add(cookie);
        return token;
    }

    public static string GetNormalizedClientIp()
    {
        string rawAddress = HttpContext.Current.Request.UserHostAddress;
        IPAddress address;
        if (!IPAddress.TryParse(rawAddress, out address))
        {
            throw new InvalidOperationException("요청 IP를 확인할 수 없습니다.");
        }

        if (address.IsIPv4MappedToIPv6)
        {
            address = address.MapToIPv4();
        }

        return address.ToString();
    }

    public static string GetBrowserHash(string browserToken)
    {
        return ComputeScopeHash("B", browserToken);
    }

    public static string GetIpHash(string normalizedIp)
    {
        return ComputeScopeHash("I", normalizedIp);
    }

    public static bool VerifyPassword(string input)
    {
        MealPrecheckSetting setting = AppConfiguration.MealPrecheck;
        byte[] salt = Convert.FromBase64String(setting.PasswordSalt);
        byte[] expected = Convert.FromBase64String(setting.PasswordHash);
        byte[] actual;

        using (Rfc2898DeriveBytes derive = new Rfc2898DeriveBytes(input ?? String.Empty, salt, setting.PasswordIterations))
        {
            actual = derive.GetBytes(expected.Length);
        }

        return ConstantTimeEquals(actual, expected);
    }

    public static MealAccessGuardState GetGuardState(string browserHash, string ipHash)
    {
        MealPrecheckSetting setting = AppConfiguration.MealPrecheck;
        DataSet data = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_access_guard_get",
            new SqlParameter("@BROWSER_HASH", browserHash),
            new SqlParameter("@IP_HASH", ipHash),
            new SqlParameter("@NOW_UTC", DateTime.UtcNow),
            new SqlParameter("@MAX_ATTEMPTS", setting.MaxAttempts),
            new SqlParameter("@WINDOW_MINUTES", setting.AttemptWindowMinutes));

        return ReadGuardState(data);
    }

    public static MealAccessGuardState RecordFailure(string browserHash, string ipHash)
    {
        MealPrecheckSetting setting = AppConfiguration.MealPrecheck;
        DataSet data = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_access_failure_record",
            new SqlParameter("@BROWSER_HASH", browserHash),
            new SqlParameter("@IP_HASH", ipHash),
            new SqlParameter("@NOW_UTC", DateTime.UtcNow),
            new SqlParameter("@MAX_ATTEMPTS", setting.MaxAttempts),
            new SqlParameter("@WINDOW_MINUTES", setting.AttemptWindowMinutes),
            new SqlParameter("@LOCKOUT_MINUTES", setting.LockoutMinutes));

        return ReadGuardState(data);
    }

    public static MealAccessGuardState TryCompleteAuthorization(string browserHash, string ipHash)
    {
        DataSet data = EfStoredProcedure.ExecuteDataSet(
            "ubfgj3.dbo.SP_meal_access_success_try",
            new SqlParameter("@BROWSER_HASH", browserHash),
            new SqlParameter("@IP_HASH", ipHash),
            new SqlParameter("@NOW_UTC", DateTime.UtcNow));

        if (data.Tables.Count == 0 || data.Tables[0].Rows.Count == 0)
        {
            throw new InvalidOperationException("접근 제한 상태를 확인할 수 없습니다.");
        }

        DataRow row = data.Tables[0].Rows[0];
        bool locked = String.Equals(Convert.ToString(row["result_code"]), "LOCKED", StringComparison.OrdinalIgnoreCase);
        return new MealAccessGuardState
        {
            IsLocked = locked,
            LockedUntilUtc = ReadUtcDate(row, "locked_until"),
            RemainingAttempts = locked ? 0 : AppConfiguration.MealPrecheck.MaxAttempts
        };
    }

    public static void CreateAuthorizedSession(string browserHash, string ipHash)
    {
        HttpSessionStateBaseAdapter session = new HttpSessionStateBaseAdapter(HttpContext.Current.Session);
        MealPrecheckSetting setting = AppConfiguration.MealPrecheck;

        session.Timeout = Math.Min(setting.SessionHours * 60, 1440);
        session[AuthorizedKey] = true;
        session[AuthorizedAtKey] = DateTime.UtcNow;
        session[AuthorizedIpKey] = ipHash;
        session[AuthorizedBrowserKey] = browserHash;
        session[CsrfKey] = CreateRandomToken(32);
    }

    public static bool IsAuthorizedSession(string browserHash, string ipHash)
    {
        HttpSessionStateBaseAdapter session = new HttpSessionStateBaseAdapter(HttpContext.Current.Session);
        object authorized = session[AuthorizedKey];
        object authorizedAtValue = session[AuthorizedAtKey];

        if (!(authorized is bool) || !(bool)authorized || !(authorizedAtValue is DateTime))
        {
            return false;
        }

        DateTime authorizedAt = DateTime.SpecifyKind((DateTime)authorizedAtValue, DateTimeKind.Utc);
        if (DateTime.UtcNow - authorizedAt > TimeSpan.FromHours(AppConfiguration.MealPrecheck.SessionHours))
        {
            ClearAuthorizedSession();
            return false;
        }

        bool matches = String.Equals(Convert.ToString(session[AuthorizedIpKey]), ipHash, StringComparison.Ordinal)
            && String.Equals(Convert.ToString(session[AuthorizedBrowserKey]), browserHash, StringComparison.Ordinal);

        if (!matches)
        {
            ClearAuthorizedSession();
        }

        return matches;
    }

    public static string GetCsrfToken()
    {
        return Convert.ToString(HttpContext.Current.Session[CsrfKey]);
    }

    public static string EnsureCsrfToken()
    {
        string token = GetCsrfToken();
        if (String.IsNullOrWhiteSpace(token))
        {
            token = CreateRandomToken(32);
            HttpContext.Current.Session[CsrfKey] = token;
        }

        return token;
    }

    public static bool ValidateCsrfToken(string submittedToken)
    {
        string expected = GetCsrfToken();
        if (String.IsNullOrEmpty(expected) || String.IsNullOrEmpty(submittedToken))
        {
            return false;
        }

        return ConstantTimeEquals(Encoding.UTF8.GetBytes(expected), Encoding.UTF8.GetBytes(submittedToken));
    }

    public static void ClearAuthorizedSession()
    {
        HttpSessionStateBaseAdapter session = new HttpSessionStateBaseAdapter(HttpContext.Current.Session);
        session.Remove(AuthorizedKey);
        session.Remove(AuthorizedAtKey);
        session.Remove(AuthorizedIpKey);
        session.Remove(AuthorizedBrowserKey);
        session.Remove(CsrfKey);
    }

    public static void SetPrivateNoStoreHeaders()
    {
        HttpResponse response = HttpContext.Current.Response;
        response.Cache.SetCacheability(HttpCacheability.NoCache);
        response.Cache.SetNoStore();
        response.Cache.SetExpires(DateTime.UtcNow.AddYears(-1));
        response.AppendHeader("Pragma", "no-cache");
        response.AppendHeader("X-Robots-Tag", "noindex, nofollow");
    }

    private static string ComputeScopeHash(string scopeType, string value)
    {
        byte[] key = Convert.FromBase64String(AppConfiguration.MealPrecheck.HmacKey);
        byte[] payload = Encoding.UTF8.GetBytes(scopeType + "|" + (value ?? String.Empty));

        using (HMACSHA256 hmac = new HMACSHA256(key))
        {
            return ToHex(hmac.ComputeHash(payload));
        }
    }

    private static MealAccessGuardState ReadGuardState(DataSet data)
    {
        if (data.Tables.Count == 0 || data.Tables[0].Rows.Count == 0)
        {
            throw new InvalidOperationException("접근 제한 상태를 확인할 수 없습니다.");
        }

        DataRow row = data.Tables[0].Rows[0];
        return new MealAccessGuardState
        {
            IsLocked = String.Equals(Convert.ToString(row["is_locked"]), "Y", StringComparison.OrdinalIgnoreCase),
            LockedUntilUtc = ReadUtcDate(row, "locked_until"),
            FailedCount = Convert.ToInt32(row["failed_count"], CultureInfo.InvariantCulture),
            RemainingAttempts = Convert.ToInt32(row["remaining_attempts"], CultureInfo.InvariantCulture)
        };
    }

    private static DateTime? ReadUtcDate(DataRow row, string columnName)
    {
        if (!row.Table.Columns.Contains(columnName) || row.IsNull(columnName))
        {
            return null;
        }

        return DateTime.SpecifyKind(Convert.ToDateTime(row[columnName], CultureInfo.InvariantCulture), DateTimeKind.Utc);
    }

    private static bool IsValidBrowserToken(string token)
    {
        if (String.IsNullOrWhiteSpace(token) || token.Length < 32 || token.Length > 100)
        {
            return false;
        }

        foreach (char value in token)
        {
            if (!(Char.IsLetterOrDigit(value) || value == '-' || value == '_'))
            {
                return false;
            }
        }

        return true;
    }

    private static string CreateRandomToken(int byteLength)
    {
        byte[] bytes = new byte[byteLength];
        using (RandomNumberGenerator random = RandomNumberGenerator.Create())
        {
            random.GetBytes(bytes);
        }

        return Convert.ToBase64String(bytes)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }

    private static bool ConstantTimeEquals(byte[] left, byte[] right)
    {
        int difference = left.Length ^ right.Length;
        int length = Math.Max(left.Length, right.Length);

        for (int i = 0; i < length; i++)
        {
            byte leftValue = i < left.Length ? left[i] : (byte)0;
            byte rightValue = i < right.Length ? right[i] : (byte)0;
            difference |= leftValue ^ rightValue;
        }

        return difference == 0;
    }

    private static string ToHex(byte[] value)
    {
        StringBuilder builder = new StringBuilder(value.Length * 2);
        foreach (byte item in value)
        {
            builder.Append(item.ToString("X2", CultureInfo.InvariantCulture));
        }

        return builder.ToString();
    }

    private static void SetSameSiteLax(HttpCookie cookie)
    {
        PropertyInfo property = typeof(HttpCookie).GetProperty("SameSite", BindingFlags.Public | BindingFlags.Instance);
        if (property == null || !property.CanWrite)
        {
            return;
        }

        object lax = Enum.Parse(property.PropertyType, "Lax", true);
        property.SetValue(cookie, lax, null);
    }

    private sealed class HttpSessionStateBaseAdapter
    {
        private readonly System.Web.SessionState.HttpSessionState _session;

        public HttpSessionStateBaseAdapter(System.Web.SessionState.HttpSessionState session)
        {
            _session = session;
        }

        public int Timeout
        {
            set { _session.Timeout = value; }
        }

        public object this[string key]
        {
            get { return _session[key]; }
            set { _session[key] = value; }
        }

        public void Remove(string key)
        {
            _session.Remove(key);
        }
    }
}
