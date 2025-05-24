using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace LabResultSystem
{
    public partial class PatientResults : System.Web.UI.Page
    {
        protected void btnShowResults_Click(object sender, EventArgs e)
        {
            string patientNationalId = txtPatientId.Text.Trim();

            if (string.IsNullOrWhiteSpace(patientNationalId))
            {
                lblMessage.Text = "يرجى إدخال رقم الهوية.";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT T.TestName, T.TestDate, T.UploadedFilePath
                    FROM TestRequests T
                    INNER JOIN Patients P ON T.PatientID = P.PatientID
                    WHERE P.NationalID = @NationalID AND T.IsProcessed = 1";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@NationalID", patientNationalId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();

                try
                {
                    conn.Open();
                    da.Fill(dt);

                    gridResults.DataSource = dt;
                    gridResults.DataBind();

                    if (dt.Rows.Count == 0)
                    {
                        lblMessage.Text = "لا توجد نتائج مرفوعة لهذا المريض.";
                    }
                    else
                    {
                        lblMessage.Text = "";
                    }
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "حدث خطأ أثناء تحميل النتائج: " + ex.Message;
                }
            }
        }
    }
}