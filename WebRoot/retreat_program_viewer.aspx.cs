using System;
using System.Web;
using System.Web.UI;

public partial class retreat_program_viewer : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.AppendHeader("X-Content-Type-Options", "nosniff");
        Response.AppendHeader("Referrer-Policy", "same-origin");
        Response.AppendHeader(
            "Content-Security-Policy",
            "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' blob: data:; font-src 'self' blob: data:; connect-src 'self'; worker-src 'self' blob:; frame-ancestors 'self'; base-uri 'none'; form-action 'none'");
    }
}
