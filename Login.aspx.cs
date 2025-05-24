using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;

namespace LabResultSystem
{
    public partial class Login : System.Web.UI.Page
    {
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            string query = "SELECT UserID, FullName FROM Users WHERE Username = @Username AND PasswordHash = @Password";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Password", password); // لاحقاً استخدم Hash

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    Session["UserID"] = reader["UserID"];
                    Session["FullName"] = reader["FullName"];
                    Response.Redirect("AllRequests.aspx");
                }
                else
                {
                    lblMessage.Text = "اسم المستخدم أو كلمة المرور غير صحيحة.";
                }
            }
        }
    }
}