using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace LabResultSystem
{
    public partial class CheckResults : System.Web.UI.Page
    {
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string nationalId = txtNationalId.Text.Trim();

            if (string.IsNullOrEmpty(nationalId))
            {
                lblMessage.Text = "يرجى إدخال رقم الهوية.";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            string query = @"
                SELECT T.TestName, T.RequestedAt, T.ProcessedAt, T.UploadedFilePath, T.IsProcessed
                FROM TestRequests T
                INNER JOIN Patients P ON T.PatientID = P.PatientID
                WHERE P.NationalID = @NationalID
                ORDER BY T.RequestedAt DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@NationalID", nationalId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gridResults.DataSource = dt;
                gridResults.DataBind();

                lblMessage.Text = dt.Rows.Count == 0 ? "لا توجد نتائج مرتبطة بهذا الرقم." : "";
            }
        }
    }
}