using System;
using System.Web.UI.WebControls;

public partial class member_findpwd : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// 암호 복구 이메일 발송
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PasswordRecovery1_SendingMail(object sender, MailMessageEventArgs e)
    {
        //이메일 제목 설정
        e.Message.Subject = "(UBF 광주3부) ubfgj3.kr 사이트 비밀번호 복구 메일";
        e.Cancel = true;
        CodeHelper.SendMail("ubfgj3", e.Message.Subject, e.Message.To[0].Address, e.Message.Body, true);
    }

}
