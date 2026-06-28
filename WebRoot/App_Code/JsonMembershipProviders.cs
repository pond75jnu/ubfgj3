using System.Collections.Specialized;
using System.Web.Security;

public class JsonSqlMembershipProvider : SqlMembershipProvider
{
    public override void Initialize(string name, NameValueCollection config)
    {
        AppConfiguration.ApplyToConfigurationManager();
        base.Initialize(name, config);
    }
}

public class JsonSqlRoleProvider : SqlRoleProvider
{
    public override void Initialize(string name, NameValueCollection config)
    {
        AppConfiguration.ApplyToConfigurationManager();
        base.Initialize(name, config);
    }
}
