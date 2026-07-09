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
        if (RedirectToCanonicalUrl())
            return;

        RewriteExtensionlessAspxUrl();
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

    private bool RedirectToCanonicalUrl()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Request == null || ctx.Response == null)
            return false;

        string path = ctx.Request.Url.AbsolutePath;
        bool isAspxPath = path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase);
        bool isDefaultPath = CodeHelper.ToCanonicalPath(path).Equals("/")
            && !path.Equals("/", StringComparison.Ordinal);

        if (!isAspxPath && !isDefaultPath)
            return false;

        string canonicalUrl = CodeHelper.ToCanonicalUrl(ctx.Request.RawUrl);
        if (canonicalUrl.Equals(ctx.Request.RawUrl, StringComparison.OrdinalIgnoreCase))
            return false;

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
        return true;
    }

    private void RewriteExtensionlessAspxUrl()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Request == null || ctx.Response == null)
            return;

        string path = ctx.Request.Url.AbsolutePath;
        if (path.Equals("/", StringComparison.Ordinal) || path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
            return;

        if (!string.IsNullOrEmpty(Path.GetExtension(path)))
            return;

        string canonicalPath = CodeHelper.ToCanonicalPath(path);
        if (canonicalPath.Equals("/", StringComparison.Ordinal))
            return;

        string appRoot = HttpRuntime.AppDomainAppPath;
        if (string.IsNullOrEmpty(appRoot))
            return;

        string relativePath = canonicalPath.TrimStart('/') + ".aspx";
        string physicalPath = Path.Combine(appRoot, relativePath.Replace('/', Path.DirectorySeparatorChar));
        if (!File.Exists(physicalPath))
            return;

        string query = ctx.Request.Url.Query;
        if (query.StartsWith("?", StringComparison.Ordinal))
            query = query.Substring(1);

        ctx.RewritePath("~/" + relativePath, string.Empty, query, false);
    }
</script>
