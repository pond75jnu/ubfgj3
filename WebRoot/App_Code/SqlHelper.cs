using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

/// <summary>
/// Sql Helper Class
/// </summary>
public class SqlHelper : System.Web.UI.Page
{
    private static string _connectionString;

    public static string ConnectionString
    {
        get
        {
            if (string.IsNullOrEmpty(_connectionString))
            {
                _connectionString = GetConnectionString();
            }
            return _connectionString;
        }
    }


    private static string GetConnectionString()
    {        

        string strDBInfo = AppConfiguration.GetConnectionString("RetreatConnectionString");
        if (!String.IsNullOrEmpty(strDBInfo))
        {
            string connString = strDBInfo;

            if (!String.IsNullOrEmpty(connString))
            {
                return strDBInfo;
            }
        }

        throw new ApplicationException("Data Base 접속 정보를 찾을수 없습니다.");
    }



    public static SqlConnection GetConnection()
    {
        return new SqlConnection(ConnectionString);
    }
    public static SqlConnection GetConnection(string connString)
    {
        return new SqlConnection(connString);
    }



    #region PrepareCommand()

    public static SqlCommand PrepareCommand(SqlConnection conn, SqlTransaction trx, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        // SqlCommand 생성 및 명령문 설정
        SqlCommand command = conn.CreateCommand();
        command.CommandText = commandText;
        command.CommandType = type;

        // 트랙잭션이 지정된 경우 명령에 트랜잭션 지정
        if (trx != null)
        {
            command.Transaction = trx;
        }

        // 파라미터를 조합하여 명령에 추가한다.
        AttachParameters(command, type, pCollection, paramKeys);

        return command;
    }

    #endregion

    #region AttachParameters(), GetParameter()

    public static void AttachParameters(SqlCommand command, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        if (pCollection != null)
        {
            if (type == CommandType.StoredProcedure && paramKeys == null)
            {
                DataSet ds = GetStoredProcedureReport(command.Connection, command.CommandText);

                if (ds != null && ds.Tables.Count >= 2 && ds.Tables[1].Rows.Count > 0)
                {
                    DataTable dt = ds.Tables[1];

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        string paramName = (string)dt.Rows[i]["Parameter_Name"];

                        SqlParameter sqlParam = GetParameter(command, pCollection, paramName);
                        if (sqlParam != null)
                        {
                            command.Parameters.Add(sqlParam);
                        }
                    }
                }
            }
            else if (type == CommandType.Text && paramKeys == null)
            {
                for (int i = 0; i < pCollection.Count; i++)
                {
                    CustomParameter cParam = pCollection[i] as CustomParameter;
                    if (cParam != null)
                    {
                        command.Parameters.AddWithValue(cParam.Name, cParam.GetValue());
                    }
                }
            }
            else if (paramKeys != null)
            {
                for (int i = 0; i < paramKeys.Length; i++)
                {
                    string paramName = paramKeys[i];

                    SqlParameter sqlParam = GetParameter(command, pCollection, paramName);
                    if (sqlParam != null)
                    {
                        command.Parameters.Add(sqlParam);
                    }
                }
            }
        }
    }

    public static SqlParameter GetParameter(SqlCommand command, ParameterCollection pCollection, string paramName)
    {
        SqlParameter sqlParam = null;

        for (int i = 0; i < pCollection.Count; i++)
        {
            if (pCollection[i].Name.Equals(paramName, StringComparison.OrdinalIgnoreCase))
            {
                CustomParameter cParam = pCollection[i] as CustomParameter;
                if (cParam != null)
                {
                    sqlParam = command.CreateParameter();
                    //sqlParam.DbType = p.Type;
                    //sqlParam.Size = p.Size;
                    sqlParam.Direction = cParam.Direction;
                    sqlParam.ParameterName = cParam.Name;
                    sqlParam.Value = cParam.GetValue();
                }
                else
                {
                    throw new ApplicationException("Please use CustomParameter. Other's not allowed yet!");
                }

                break;
            }
        }

        return sqlParam;
    }


    #endregion

    #region GetStoredProcedureReport()

    public static DataSet GetStoredProcedureReport(SqlConnection conn, string spName)
    {
        DataSet ds = null;

        if (conn != null && !String.IsNullOrEmpty(spName))
        {
            SqlCommand command = conn.CreateCommand();
            command.CommandText = "sp_help";
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@objname", spName));

            ds = new DataSet("StoredProcedure");
            SqlDataAdapter adpt = new SqlDataAdapter(command);
            adpt.Fill(ds);
        }

        return ds;
    }

    #endregion

    #region ExecuteDataSet()

    public static DataSet ExecuteDataSet(SqlConnection conn, SqlTransaction trx, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        SqlCommand command = PrepareCommand(conn, trx, commandText, type, pCollection, paramKeys);
        command.CommandTimeout = 3600;

        DataSet ds = new DataSet();
        SqlDataAdapter adpt = new SqlDataAdapter(command);
        adpt.Fill(ds);

        return ds;
    }

    public static DataSet ExecuteDataSet(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        SqlCommand command = PrepareCommand(conn, null, commandText, type, pCollection, paramKeys);
        command.CommandTimeout = 3600;

        DataSet ds = new DataSet();
        SqlDataAdapter adpt = new SqlDataAdapter(command);
        adpt.Fill(ds);

        return ds;
    }

    public static DataSet ExecuteDataSet(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection)
    {
        return ExecuteDataSet(conn, commandText, type, pCollection, null);
    }

    public static DataSet ExecuteDataSet(SqlConnection conn, string commandText, CommandType type)
    {
        return ExecuteDataSet(conn, commandText, type, null, null);
    }

    public static DataSet ExecuteDataSet(SqlConnection conn, string commandText)
    {
        return ExecuteDataSet(conn, commandText, CommandType.StoredProcedure, null, null);
    }

    #endregion

    #region ExecuteNonQuery()

    public static int ExecuteNonQuery(SqlConnection conn, SqlTransaction trx, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        int rowCount = 0;
        bool openConnect = false;

        SqlCommand command = PrepareCommand(conn, trx, commandText, type, pCollection, paramKeys);
        command.CommandTimeout = 3600;

        if (conn.State == ConnectionState.Closed)
        {
            conn.Open();
            openConnect = true;
        }

        rowCount = command.ExecuteNonQuery();

        if (openConnect)
        {
            conn.Close();
        }

        return rowCount;
    }

    public static int ExecuteNonQuery(SqlConnection conn, SqlTransaction trx, string commandText, CommandType type, ParameterCollection pCollection)
    {
        return ExecuteNonQuery(conn, trx, commandText, type, pCollection, null);
    }

    public static int ExecuteNonQuery(SqlConnection conn, SqlTransaction trx, string commandText, CommandType type)
    {
        return ExecuteNonQuery(conn, trx, commandText, type, null, null);
    }

    public static int ExecuteNonQuery(SqlConnection conn, SqlTransaction trx, string commandText)
    {
        return ExecuteNonQuery(conn, trx, commandText, CommandType.StoredProcedure, null, null);
    }

    public static int ExecuteNonQuery(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        return ExecuteNonQuery(conn, null, commandText, type, pCollection, paramKeys);
    }

    public static int ExecuteNonQuery(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection)
    {
        return ExecuteNonQuery(conn, null, commandText, type, pCollection, null);
    }

    public static int ExecuteNonQuery(SqlConnection conn, string commandText, CommandType type)
    {
        return ExecuteNonQuery(conn, null, commandText, type, null, null);
    }

    public static int ExecuteNonQuery(SqlConnection conn, string commandText)
    {
        return ExecuteNonQuery(conn, null, commandText, CommandType.StoredProcedure, null, null);
    }

    #endregion

    #region ExecuteScalar()

    public static object ExecuteScalar(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection, string[] paramKeys)
    {
        object oScalar = null;
        bool openConnect = false;

        SqlCommand command = PrepareCommand(conn, null, commandText, type, pCollection, paramKeys);
        command.CommandTimeout = 3600;

        if (conn.State == ConnectionState.Closed)
        {
            conn.Open();
            openConnect = true;
        }

        oScalar = command.ExecuteScalar();

        if (openConnect)
        {
            conn.Close();
        }

        return oScalar;
    }

    public static object ExecuteScalar(SqlConnection conn, string commandText, CommandType type, ParameterCollection pCollection)
    {
        return ExecuteScalar(conn, commandText, type, pCollection, null);
    }

    public static object ExecuteScalar(SqlConnection conn, string commandText, CommandType type)
    {
        return ExecuteScalar(conn, commandText, type, null, null);
    }

    public static object ExecuteScalar(SqlConnection conn, string commandText)
    {
        return ExecuteScalar(conn, commandText, CommandType.StoredProcedure, null, null);
    }

    #endregion




}
