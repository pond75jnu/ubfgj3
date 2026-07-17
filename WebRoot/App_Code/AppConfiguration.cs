using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Reflection;
using System.Web.Hosting;
using System.Web.Script.Serialization;

public static class AppConfiguration
{
    private const string DefaultSettingsFile = "appsettings.json";
    private static readonly object SyncRoot = new object();
    private static AppSettingsData _settings;
    private static bool _configurationManagerApplied;

    public static AppSettingsData Settings
    {
        get { return LoadSettings(); }
    }

    public static string GetConnectionString(string name)
    {
        ConnectionStringSettings settings = GetConnectionStringSettings(name);
        return settings.ConnectionString;
    }

    public static ConnectionStringSettings GetConnectionStringSettings(string name)
    {
        ConnectionStringSetting setting;
        if (!Settings.ConnectionStrings.TryGetValue(name, out setting) || setting == null || String.IsNullOrEmpty(setting.ConnectionString))
        {
            throw new ConfigurationErrorsException("appsettings.json에서 DB 연결 문자열을 찾을 수 없습니다: " + name);
        }

        return new ConnectionStringSettings(
            name,
            setting.ConnectionString,
            String.IsNullOrEmpty(setting.ProviderName) ? "System.Data.SqlClient" : setting.ProviderName);
    }

    public static SmtpSetting Smtp
    {
        get
        {
            if (Settings.Smtp == null)
            {
                throw new ConfigurationErrorsException("appsettings.json에서 SMTP 설정을 찾을 수 없습니다.");
            }

            return Settings.Smtp;
        }
    }

    public static MealPrecheckSetting MealPrecheck
    {
        get
        {
            MealPrecheckSetting setting = Settings.MealPrecheck;
            if (setting == null)
            {
                throw new ConfigurationErrorsException("appsettings.json에서 식사 사전조사 설정을 찾을 수 없습니다.");
            }

            setting.Validate();
            return setting;
        }
    }

    public static void ApplyToConfigurationManager()
    {
        if (_configurationManagerApplied)
        {
            return;
        }

        lock (SyncRoot)
        {
            if (_configurationManagerApplied)
            {
                return;
            }

            ConnectionStringSettings retreatConnectionString = GetConnectionStringSettings("RetreatConnectionString");
            ConnectionStringSettingsCollection connectionStrings = ConfigurationManager.ConnectionStrings;

            SetReadOnly(connectionStrings, false);

            ConnectionStringSettings existing = connectionStrings[retreatConnectionString.Name];
            if (existing == null)
            {
                connectionStrings.Add(retreatConnectionString);
            }
            else
            {
                SetReadOnly(existing, false);
                existing.ConnectionString = retreatConnectionString.ConnectionString;
                existing.ProviderName = retreatConnectionString.ProviderName;
            }

            _configurationManagerApplied = true;
        }
    }

    private static AppSettingsData LoadSettings()
    {
        if (_settings != null)
        {
            return _settings;
        }

        lock (SyncRoot)
        {
            if (_settings != null)
            {
                return _settings;
            }

            string settingsPath = GetSettingsPath();
            if (!File.Exists(settingsPath))
            {
                throw new ConfigurationErrorsException("설정 파일을 찾을 수 없습니다: " + settingsPath);
            }

            JavaScriptSerializer serializer = new JavaScriptSerializer();
            _settings = serializer.Deserialize<AppSettingsData>(File.ReadAllText(settingsPath));

            if (_settings == null)
            {
                throw new ConfigurationErrorsException("appsettings.json을 읽을 수 없습니다.");
            }

            if (_settings.ConnectionStrings == null)
            {
                _settings.ConnectionStrings = new Dictionary<string, ConnectionStringSetting>(StringComparer.OrdinalIgnoreCase);
            }
            else
            {
                _settings.ConnectionStrings = new Dictionary<string, ConnectionStringSetting>(_settings.ConnectionStrings, StringComparer.OrdinalIgnoreCase);
            }

            return _settings;
        }
    }

    private static string GetSettingsPath()
    {
        string configuredFile = ConfigurationManager.AppSettings["ExternalSettingsFile"];
        if (String.IsNullOrEmpty(configuredFile))
        {
            configuredFile = DefaultSettingsFile;
        }

        string mappedPath = HostingEnvironment.MapPath("~/" + configuredFile.TrimStart('~', '/', '\\'));
        if (!String.IsNullOrEmpty(mappedPath))
        {
            return mappedPath;
        }

        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, configuredFile);
    }

    private static void SetReadOnly(object target, bool readOnly)
    {
        Type currentType = target.GetType();
        while (currentType != null)
        {
            FieldInfo field = currentType.GetField("_bReadOnly", BindingFlags.Instance | BindingFlags.NonPublic)
                ?? currentType.GetField("bReadOnly", BindingFlags.Instance | BindingFlags.NonPublic);

            if (field != null && field.FieldType == typeof(bool))
            {
                field.SetValue(target, readOnly);
                return;
            }

            currentType = currentType.BaseType;
        }
    }
}

public class AppSettingsData
{
    public Dictionary<string, ConnectionStringSetting> ConnectionStrings { get; set; }
    public SmtpSetting Smtp { get; set; }
    public MealPrecheckSetting MealPrecheck { get; set; }
}

public class ConnectionStringSetting
{
    public string ConnectionString { get; set; }
    public string ProviderName { get; set; }
}

public class SmtpSetting
{
    public string From { get; set; }
    public string Host { get; set; }
    public int Port { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public bool EnableSsl { get; set; }
    public bool DefaultCredentials { get; set; }
}

public class MealPrecheckSetting
{
    public string PasswordHash { get; set; }
    public string PasswordSalt { get; set; }
    public int PasswordIterations { get; set; }
    public string HmacKey { get; set; }
    public int MaxAttempts { get; set; }
    public int AttemptWindowMinutes { get; set; }
    public int LockoutMinutes { get; set; }
    public int SessionHours { get; set; }
    public int MaxRetreatDays { get; set; }

    public void Validate()
    {
        if (String.IsNullOrWhiteSpace(PasswordHash)
            || String.IsNullOrWhiteSpace(PasswordSalt)
            || String.IsNullOrWhiteSpace(HmacKey))
        {
            throw new ConfigurationErrorsException("식사 사전조사 비밀 설정이 누락되었습니다.");
        }

        if (PasswordIterations < 10000
            || MaxAttempts < 1
            || AttemptWindowMinutes < 1
            || LockoutMinutes < 1
            || SessionHours < 1
            || MaxRetreatDays < 1)
        {
            throw new ConfigurationErrorsException("식사 사전조사 제한 설정이 올바르지 않습니다.");
        }

        try
        {
            if (Convert.FromBase64String(PasswordHash).Length < 20
                || Convert.FromBase64String(PasswordSalt).Length < 16
                || Convert.FromBase64String(HmacKey).Length < 32)
            {
                throw new ConfigurationErrorsException("식사 사전조사 비밀 설정 길이가 올바르지 않습니다.");
            }
        }
        catch (FormatException ex)
        {
            throw new ConfigurationErrorsException("식사 사전조사 비밀 설정 형식이 올바르지 않습니다.", ex);
        }
    }
}
