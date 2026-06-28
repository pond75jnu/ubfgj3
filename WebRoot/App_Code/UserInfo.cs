using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

/// <summary>
/// UserInfo의 요약 설명입니다.
/// </summary>
public class UserInfo
{
    public UserInfo()
    {
        //
        // TODO: 여기에 생성자 논리를 추가합니다.
        //
    }

    /// <summary>
    /// 아이디 확인
    /// </summary>
    /// <returns></returns>
    public static string UserID
    {
        get
        {
            try
            {
                var user = Membership.GetUser();

                if (user == null)
                {
                    return "Anonymous";
                }
                else
                {
                    return Membership.GetUser().UserName;
                }
            }
            catch (Exception)
            {

                return "Anonymous";
            }
        }
    }

    /// <summary>
    /// 역할 확인
    /// </summary>
    /// <returns></returns>
    public static string UserRole
    {
        get
        {
            try
            {
                var user = Membership.GetUser();

                if (user != null)
                {
                    return RoleName(UserId(Membership.GetUser().UserName));
                }
                else
                {
                    return "Anonymous";
                }
                    
            }
            catch (Exception)
            {

                return "Anonymous";
            }
        }
    }

    /// <summary>
    /// 역할설명 확인
    /// </summary>
    /// <returns></returns>
    public static string UserRoleDesc
    {
        get
        {
            try
            {
                return RoleDesc(UserId(Membership.GetUser().UserName));
            }
            catch (Exception)
            {

                return "Anonymous";
            }
        }
    }

    /// <summary>
    /// 사용자email
    /// </summary>
    public static string UserEmail
    {
        get
        {
            try
            {
                return Membership.GetUser().Email;
            }
            catch (Exception)
            {

                return "Anonymous";
            }
        }
    }

    /// <summary>
    ///  로그인 사용자의 이름 반환
    /// </summary>
    public static string LoginUserKOR_NM
    {
        get
        {
            try
            {
                MembershipUser user = Membership.GetUser();

                DataSet ds = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_member_master_by_login_sel",
                    new SqlParameter("@LoginId", user.ToString().ToLower()));

                if (ds.Tables[0].Rows.Count > 0)
                {
                    return ds.Tables[0].Rows[0]["kor_nm"].ToString();
                }
                else
                {
                    return string.Empty;
                }
            }
            catch (Exception)
            {

                return string.Empty;
            }


        }
    }

    /// <summary>
    ///  로그인 사용자의 소속(요회) 코드 반환
    /// </summary>
    public static string LoginUserBelongCode
    {
        get
        {
            try
            {
                MembershipUser user = Membership.GetUser();

                DataSet ds = EfStoredProcedure.ExecuteDataSet(
                    "ubfgj3.dbo.SP_member_master_by_login_sel",
                    new SqlParameter("@LoginId", user.ToString().ToLower()));

                if (ds.Tables[0].Rows.Count > 0)
                {
                    return ds.Tables[0].Rows[0]["belong"].ToString();
                }
                else
                {
                    return string.Empty;
                }
            }
            catch (Exception)
            {

                return string.Empty;
            }


        }
    }

    /// <summary>
    ///  로그인 아이디로 사용자의 UserId 반환
    /// </summary>
    public static string UserId(string login_id)
    {
        try
        {
            
            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_userinfo_userid_sel",
                new SqlParameter("@LoginId", login_id.ToLower()));

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["UserId"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }
        catch (Exception)
        {

            return string.Empty;
        }
    }

    /// <summary>
    /// RoleName으로 RoleId 반환
    /// </summary>
    public static string RoleId(string rolename)
    {
        try
        {

            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_userinfo_roleid_sel",
                new SqlParameter("@RoleName", rolename));

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["RoleId"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }
        catch (Exception)
        {

            return string.Empty;
        }
    }


    /// <summary>
    /// UserId로 RoleName 반환
    /// </summary>
    public static string RoleName(string UserId)
    {
        try
        {

            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_userinfo_role_by_userid_sel",
                new SqlParameter("@UserId", UserId));

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["UserRole"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }
        catch (Exception)
        {

            return string.Empty;
        }
    }

    /// <summary>
    /// UserId로 Role설명 반환
    /// </summary>
    public static string RoleDesc(string UserId)
    {
        try
        {

            DataSet ds = EfStoredProcedure.ExecuteDataSet(
                "ubfgj3.dbo.SP_userinfo_role_by_userid_sel",
                new SqlParameter("@UserId", UserId));

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["RoleDesc"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }
        catch (Exception)
        {

            return string.Empty;
        }
    }

}
