using System;
using System.Data;
using System.Data.Common;
using System.Data.Entity;
using System.Data.SqlClient;

public class RetreatDbContext : DbContext
{
    public RetreatDbContext()
        : base(AppConfiguration.GetConnectionString("RetreatConnectionString"))
    {
        Database.SetInitializer<RetreatDbContext>(null);
    }
}

public static class EfStoredProcedure
{
    public static DataSet ExecuteDataSet(string procedureName, params SqlParameter[] parameters)
    {
        using (RetreatDbContext context = new RetreatDbContext())
        {
            using (DbCommand command = CreateCommand(context, procedureName, parameters))
            {
                using (SqlDataAdapter adapter = new SqlDataAdapter((SqlCommand)command))
                {
                    DataSet dataSet = new DataSet();
                    adapter.Fill(dataSet);
                    return dataSet;
                }
            }
        }
    }

    public static int ExecuteNonQuery(string procedureName, params SqlParameter[] parameters)
    {
        using (RetreatDbContext context = new RetreatDbContext())
        {
            using (DbCommand command = CreateCommand(context, procedureName, parameters))
            {
                OpenConnection(context);
                return command.ExecuteNonQuery();
            }
        }
    }

    public static object ExecuteScalar(string procedureName, params SqlParameter[] parameters)
    {
        using (RetreatDbContext context = new RetreatDbContext())
        {
            using (DbCommand command = CreateCommand(context, procedureName, parameters))
            {
                OpenConnection(context);
                return command.ExecuteScalar();
            }
        }
    }

    public static SqlParameter Parameter(string name, object value)
    {
        return new SqlParameter(name, value ?? DBNull.Value);
    }

    private static DbCommand CreateCommand(RetreatDbContext context, string procedureName, SqlParameter[] parameters)
    {
        DbCommand command = context.Database.Connection.CreateCommand();
        command.CommandText = procedureName;
        command.CommandType = CommandType.StoredProcedure;

        if (parameters != null)
        {
            foreach (SqlParameter parameter in parameters)
            {
                command.Parameters.Add(parameter);
            }
        }

        return command;
    }

    private static void OpenConnection(RetreatDbContext context)
    {
        if (context.Database.Connection.State != ConnectionState.Open)
        {
            context.Database.Connection.Open();
        }
    }
}
