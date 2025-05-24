using System;
using System.Configuration;
using System.Data.SqlClient;

namespace LabResultSystem
{
    public partial class PatientRequest : System.Web.UI.Page
    {
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string nationalId = txtNationalId.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(nationalId))
            {
                lblMessage.Text = "يرجى إدخال الاسم ورقم الهوية.";
                lblMessage.CssClass = "text-danger";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                int patientId;
                string findPatientQuery = "SELECT PatientID FROM Patients WHERE NationalID = @NationalID";
                SqlCommand findCmd = new SqlCommand(findPatientQuery, conn);
                findCmd.Parameters.AddWithValue("@NationalID", nationalId);

                var result = findCmd.ExecuteScalar();
                if (result != null)
                {
                    patientId = Convert.ToInt32(result);
                }
                else
                {
                    string insertPatient = @"
                        INSERT INTO Patients (FullName, NationalID, Phone, Email)
                        OUTPUT INSERTED.PatientID
                        VALUES (@FullName, @NationalID, @Phone, @Email)";

                    SqlCommand insertCmd = new SqlCommand(insertPatient, conn);
                    insertCmd.Parameters.AddWithValue("@FullName", name);
                    insertCmd.Parameters.AddWithValue("@NationalID", nationalId);
                    insertCmd.Parameters.AddWithValue("@Phone", phone);
                    insertCmd.Parameters.AddWithValue("@Email", email);
                    patientId = (int)insertCmd.ExecuteScalar();
                }

                string insertRequest = @"
                    INSERT INTO TestRequests (PatientID, TestName, TestDate, IsProcessed, RequestedAt)
                    VALUES (@PatientID, N'طلب فحص من المريض', GETDATE(), 0, GETDATE())";

                SqlCommand reqCmd = new SqlCommand(insertRequest, conn);
                reqCmd.Parameters.AddWithValue("@PatientID", patientId);
                reqCmd.ExecuteNonQuery();

                lblMessage.Text = "تم إرسال الطلب بنجاح. سنقوم بالتواصل معك حال توفر النتيجة.";
                lblMessage.CssClass = "text-success";
            }
        }
    }
}