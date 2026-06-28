using System;
using System.Web.Security;

public partial class member_login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (Membership.ValidateUser(txtLoginID.Text, txtLoginPWD.Text))
        {
            MembershipUser user = Membership.GetUser(txtLoginID.Text);

            user.Comment = "0";

            Membership.UpdateUser(user);

            FormsAuthentication.RedirectFromLoginPage(txtLoginID.Text, chkbRememberMe.Checked);

        }
        else
        {
            MembershipUser user = Membership.GetUser(txtLoginID.Text);
            if (user != null)
            {
                if (user.IsApproved.Equals(true))
                {
                    int count = Convert.ToInt32(user.Comment) + 1;
                    user.Comment = count.ToString();

                    if (count >= Membership.MaxInvalidPasswordAttempts)
                    {
                        user.IsApproved = false;
                        lblLoginFailure.Text = "<br />" + user.UserName + "의 계정이 잠금되어 사용할 수 없습니다.<br />"
                                             + "관리자에게 문의바랍니다.";
                    }
                    else
                    {
                        lblLoginFailure.Text = "<br />로그인 실패!<br /> 앞으로"
                                             + (Membership.MaxInvalidPasswordAttempts - count)
                                             + "번 더 실패하면 " + user.UserName + "의 계정은 잠깁니다.";
                    }

                    Membership.UpdateUser(user);
                }
                else
                {
                    user.Comment = "0";
                    lblLoginFailure.Text = "<br />" + user.UserName + "의 계정이 잠금되어 사용할 수 없습니다.<br />"
                                             + "관리자에게 문의바랍니다.";
                    Membership.UpdateUser(user);
                }
            }
        }
    }

}