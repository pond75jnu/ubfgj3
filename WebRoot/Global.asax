<%@ Application Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Routing" %>

<script runat="server">
    protected void Application_Start(object sender, EventArgs e)
    {
        RegisterExtensionlessRoutes(RouteTable.Routes);
    }

    protected void Application_BeginRequest(object sender, EventArgs e)
    {
        RedirectToCanonicalUrl();
    }

    private static void RegisterExtensionlessRoutes(RouteCollection routes)
    {
        string appRoot = HttpRuntime.AppDomainAppPath;
        if (string.IsNullOrEmpty(appRoot) || !Directory.Exists(appRoot))
            return;

        foreach (string filePath in Directory.GetFiles(appRoot, "*.aspx", SearchOption.AllDirectories))
        {
            string relativePath = filePath.Substring(appRoot.Length)
                .Replace(Path.DirectorySeparatorChar, '/')
                .Replace(Path.AltDirectorySeparatorChar, '/');

            if (relativePath.Equals("Default.aspx", StringComparison.OrdinalIgnoreCase))
                continue;

            string routeUrl = relativePath.Substring(0, relativePath.Length - ".aspx".Length).ToLowerInvariant();
            string virtualPath = "~/" + relativePath;
            string routeName = "Extensionless_" + routeUrl.Replace("/", "_").Replace("-", "_");

            routes.MapPageRoute(routeName, routeUrl, virtualPath, false);
        }
    }

    private void RedirectToCanonicalUrl()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Request == null || ctx.Response == null)
            return;

        string path = ctx.Request.Url.AbsolutePath;
        bool isAspxPath = path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase);
        bool isDefaultPath = CodeHelper.ToCanonicalPath(path).Equals("/")
            && !path.Equals("/", StringComparison.Ordinal);

        if (!isAspxPath && !isDefaultPath)
            return;

        string canonicalUrl = CodeHelper.ToCanonicalUrl(ctx.Request.RawUrl);
        if (canonicalUrl.Equals(ctx.Request.RawUrl, StringComparison.OrdinalIgnoreCase))
            return;

        if (ctx.Request.HttpMethod.Equals("GET", StringComparison.OrdinalIgnoreCase)
            || ctx.Request.HttpMethod.Equals("HEAD", StringComparison.OrdinalIgnoreCase))
        {
            ctx.Response.RedirectPermanent(canonicalUrl, false);
        }
        else
        {
            ctx.Response.StatusCode = 308;
            ctx.Response.RedirectLocation = canonicalUrl;
        }

        ctx.ApplicationInstance.CompleteRequest();
    }
</script>
