using System;
using System.Web.Security;

public partial class member_logout : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        FormsAuthentication.SignOut();
        Roles.DeleteCookie();
        Session.Clear();

        Response.Redirect("/", false);
    }
}