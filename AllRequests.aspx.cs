using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Web.Services;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;

namespace LabResultSystem
{
    [System.Web.Script.Services.ScriptService]
    public partial class AllRequests : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
                LoadAllRequests();
        }

        private void LoadAllRequests(string nameFilter = "", string dateFilter = "", string statusFilter = "")
        {
            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            string query = @"
                SELECT R.RequestID, P.FullName, R.LabNote, P.NationalID, P.Phone, R.TestName, R.TestDate, 
                       R.UploadedFilePath, R.IsProcessed, R.RequestedAt, R.ProcessedAt
                FROM TestRequests R
                INNER JOIN Patients P ON R.PatientID = P.PatientID
                WHERE 1 = 1";

            if (!string.IsNullOrEmpty(nameFilter))
                query += " AND P.FullName LIKE @Name";

            if (!string.IsNullOrEmpty(dateFilter))
                query += " AND CAST(R.TestDate AS DATE) = @TestDate";

            if (!string.IsNullOrEmpty(statusFilter))
                query += " AND R.IsProcessed = @Status";

            query += " ORDER BY R.RequestedAt DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(query, conn);

                if (!string.IsNullOrEmpty(nameFilter))
                    cmd.Parameters.AddWithValue("@Name", "%" + nameFilter + "%");

                if (!string.IsNullOrEmpty(dateFilter))
                    cmd.Parameters.AddWithValue("@TestDate", DateTime.Parse(dateFilter));

                if (!string.IsNullOrEmpty(statusFilter))
                    cmd.Parameters.AddWithValue("@Status", statusFilter == "true");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gridRequests.DataSource = dt;
                gridRequests.DataBind();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string name = txtSearchName.Text.Trim();
            string date = txtSearchDate.Text.Trim();
            string status = ddlStatusFilter.SelectedValue;

            LoadAllRequests(name, date, status);
        }

        [WebMethod]
        public static List<string> GetNames(string prefix)
        {
            List<string> names = new List<string>();
            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT DISTINCT FullName FROM Patients WHERE FullName LIKE @Prefix + '%'";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    names.Add(reader["FullName"].ToString());
                }
            }

            return names;
        }

        protected void gridRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string requestId = e.CommandArgument.ToString();

            if (e.CommandName == "UploadResult")
            {
                hiddenRequestId.Value = requestId;
                ScriptManager.RegisterStartupScript(this, GetType(), "noteModalScript", "$('#noteModal').modal('show');", true);
            }
            else if (e.CommandName == "AddNoteOnly")
            {
                hiddenRequestId.Value = requestId;
                txtLabNote.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, GetType(), "noteOnlyModalScript", "$('#noteModal').modal('show');", true);
            }
            else if (e.CommandName == "DuplicateRequest")
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString))
                {
                    conn.Open();
                    string sql = @"INSERT INTO TestRequests (PatientID, TestName, TestDate, RequestedAt, IsProcessed)
                                   SELECT PatientID, TestName, GETDATE(), GETDATE(), 0 FROM TestRequests WHERE RequestID = @RequestID";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@RequestID", Guid.Parse(requestId));
                    cmd.ExecuteNonQuery();
                }
                LoadAllRequests();
            }
            else if (e.CommandName == "DeleteRequest")
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString))
                {
                    conn.Open();
                    string sql = "DELETE FROM TestRequests WHERE RequestID = @RequestID";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@RequestID", Guid.Parse(requestId));
                    cmd.ExecuteNonQuery();
                }
                LoadAllRequests();
            }
        }

        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            string requestId = hiddenRequestId.Value;
            string note = txtLabNote.Text.Trim();
            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            string phone = "", name = "مريض";

            if (string.IsNullOrEmpty(requestId))
            {
                lblMessage.Text = "لا يوجد طلب محدد.";
                lblMessage.CssClass = "text-danger";
                return;
            }

            string clickedButtonId = ((Button)sender).ID;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sqlPhone = @"SELECT P.Phone, P.FullName FROM TestRequests R INNER JOIN Patients P ON R.PatientID = P.PatientID WHERE R.RequestID = @RequestID";
                SqlCommand cmdPhone = new SqlCommand(sqlPhone, conn);
                cmdPhone.Parameters.AddWithValue("@RequestID", Guid.Parse(requestId));
                conn.Open();
                using (SqlDataReader reader = cmdPhone.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        phone = reader["Phone"].ToString();
                        name = reader["FullName"].ToString();
                    }
                }
                conn.Close();
            }

            if (clickedButtonId == "btnUploadWithNote")
            {
                if (fileUploadModal.HasFile && Path.GetExtension(fileUploadModal.FileName).ToLower() == ".pdf")
                {
                    try
                    {
                        string folderPath = Server.MapPath("~/Uploads/");
                        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);

                        string fileName = Guid.NewGuid() + ".pdf";
                        string fullPath = Path.Combine(folderPath, fileName);
                        fileUploadModal.SaveAs(fullPath);
                        string dbPath = "/Uploads/" + fileName;

                        using (SqlConnection conn = new SqlConnection(connStr))
                        {
                            string sql = @"UPDATE TestRequests SET UploadedFilePath = @FilePath, LabNote = @Note, IsProcessed = 1, ProcessedAt = GETDATE() WHERE RequestID = @RequestID";
                            SqlCommand cmd = new SqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@FilePath", dbPath);
                            cmd.Parameters.AddWithValue("@Note", note);
                            cmd.Parameters.AddWithValue("@RequestID", Guid.Parse(requestId));
                            conn.Open();
                            cmd.ExecuteNonQuery();
                        }

                        if (!string.IsNullOrEmpty(phone))
                        {
                            SendWhatsAppMessage(phone, "✅ تم رفع نتيجتك في المختبر، يمكنك تحميلها من البوابة.");
                        }

                        lblMessage.Text = "تم رفع النتيجة وتسجيل الملاحظة.";
                        lblMessage.CssClass = "text-success";
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "❌ خطأ أثناء رفع الملف: " + ex.Message;
                        lblMessage.CssClass = "text-danger";
                    }
                }
                else
                {
                    lblMessage.Text = "يرجى اختيار ملف PDF.";
                    lblMessage.CssClass = "text-warning";
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "UPDATE TestRequests SET LabNote = @Note WHERE RequestID = @RequestID";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Note", note);
                    cmd.Parameters.AddWithValue("@RequestID", Guid.Parse(requestId));
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                if (!string.IsNullOrEmpty(phone))
                {
                    string msg = $"مرحباً {name}، تم تسجيل ملاحظة على أحد فحوصاتك. يرجى الدخول إلى بوابة المريض للاطلاع على التفاصيل: https://lab.ish.ps";
                    SendWhatsAppMessage(phone, msg);
                }

                lblMessage.Text = "✅ تم حفظ الملاحظة بدون رفع نتيجة.";
                lblMessage.CssClass = "text-info";
            }

            txtLabNote.Text = string.Empty;
            hiddenRequestId.Value = string.Empty;
            LoadAllRequests();
        }

        public void SendWhatsAppMessage(string phone, string message)
        {
            var httpClient = new HttpClient();
            var payload = new { phone = phone, message = message };
            var json = JsonConvert.SerializeObject(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = httpClient.PostAsync("http://localhost:3000/send", content).Result;
            }
            catch (Exception ex)
            {
                // Logging optional
            }
        }
    }
}