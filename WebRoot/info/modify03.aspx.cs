using System;
using System.Web;

public partial class info_modify03 : System.Web.UI.Page
{
    string _path = CodeHelper.GetCurrentCanonicalPath();

    protected void Page_Load(object sender, EventArgs e)
    {
        lblPageTitle.Text = CodeHelper.GetPagetitle(_path);
    }
}