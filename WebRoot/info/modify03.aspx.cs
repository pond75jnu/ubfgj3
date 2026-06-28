using System;
using System.Web;

public partial class info_modify03 : System.Web.UI.Page
{
    string _path = HttpContext.Current.Request.Url.AbsolutePath.ToLower();

    protected void Page_Load(object sender, EventArgs e)
    {
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);
    }
}