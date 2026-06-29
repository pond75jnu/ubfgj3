using System;
using System.Web;

public partial class master_master_main_noframe : System.Web.UI.MasterPage
{
    private string _url_scheme = HttpContext.Current.Request.Url.Scheme;
    private string _domain = HttpContext.Current.Request.Url.Host;
    private string _path = CodeHelper.ToCanonicalUrl(HttpContext.Current.Request.Url.PathAndQuery);

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((_domain.ToLower().Equals("ubfgj3.kr") || _domain.ToLower().Equals("www.ubfgj3.kr")) && _url_scheme.ToLower().Equals("http"))
            Response.Redirect("https://" + _domain + _path, false);
    }
}
