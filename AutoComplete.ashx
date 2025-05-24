// ✅ AutoComplete.ashx (C# Web Handler)
<%@ WebHandler Language="C#" Class="AutoComplete" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public class AutoComplete : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
        string type = context.Request["type"];
        string term = context.Request["term"];

        List<string> suggestions = new List<string>();

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string query = type == "name"
                ? "SELECT DISTINCT TOP 10 FullName FROM Patients WHERE FullName LIKE @term"
                : "SELECT DISTINCT TOP 10 NationalID FROM Patients WHERE NationalID LIKE @term";

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@term", "%" + term + "%");
            conn.Open();
            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                suggestions.Add(reader[0].ToString());
            }
        }

        var json = new JavaScriptSerializer().Serialize(suggestions);
        context.Response.ContentType = "application/json";
        context.Response.Write(json);
    }

    public bool IsReusable => false;
}
