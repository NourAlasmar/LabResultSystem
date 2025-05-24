using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LabResultSystem
{
    public partial class PatientPortal : System.Web.UI.Page
    {
        protected DataTable ResultData;
        protected string PatientNameForMessage = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.Cookies["PatientData"] != null)
                {
                    HttpCookie cookie = Request.Cookies["PatientData"];
                    txtFullName.Text = Server.UrlDecode(cookie["FullName"]);
                    txtNationalId.Text = Server.UrlDecode(cookie["NationalID"]);
                    txtPhone.Text = Server.UrlDecode(cookie["Phone"]);
                }

                gridResults.Visible = false;

                if (Session["PatientName"] != null)
                {
                    lblWelcome.Text = $"مرحباً {Session["PatientName"]} 👋";
                    lblWelcome.Visible = true;
                    PatientNameForMessage = Session["PatientName"].ToString();
                }
                else
                {
                    lblWelcome.Visible = false;
                }
            }
        }

        protected void btnShowRequestForm_Click(object sender, EventArgs e)
        {
            panelRequestForm.Visible = true;
            panelResultsForm.Visible = false;
            gridResults.Visible = false;
            lblMessage.Text = "";
            lblMessage.CssClass = "";
        }

        protected void btnShowResultsForm_Click(object sender, EventArgs e)
        {
            panelRequestForm.Visible = false;
            panelResultsForm.Visible = true;
            gridResults.Visible = false;
            lblMessage.Text = "";
            lblMessage.CssClass = "";
        }

        protected void btnRequestTest_Click(object sender, EventArgs e)
        {
            string name = txtFullName.Text.Trim();
            string nationalId = txtNationalId.Text.Trim();
            string phonePrefix = ddlPhonePrefix.SelectedValue;
            string phoneNumber = txtPhone.Text.Trim();
            string phone = "";

            // تحقق فقط إذا كان الرقم غير فارغ
            if (!string.IsNullOrEmpty(phoneNumber))
            {
                if (!Regex.IsMatch(phoneNumber, @"^\d{9}$"))
                {
                    lblPhoneError.Text = "⚠️ رقم الهاتف يجب أن يتكون من 9 أرقام.";
                    lblPhoneError.Visible = true;
                    return;
                }
                else if (phoneNumber.StartsWith("0"))
                {
                    lblPhoneError.Text = "⚠️ يرجى عدم إدخال الرقم بصيغة تبدأ بـ 0.";
                    lblPhoneError.Visible = true;
                    return;
                }
                else
                {
                    lblPhoneError.Visible = false;
                    phone = phonePrefix + phoneNumber;
                }
            }

            if (string.IsNullOrEmpty(name))
            {
                ShowMessage("يرجى إدخال الاسم الكامل.", "alert-danger");
                return;
            }

            if (string.IsNullOrEmpty(nationalId) || !Regex.IsMatch(nationalId, @"^\d{9}$"))
            {
                ShowMessage("يرجى إدخال رقم هوية صحيح يتكون من 9 أرقام.", "alert-danger");
                return;
            }

            Session["PatientName"] = name;
            Session["NationalID"] = nationalId;
            PatientNameForMessage = name;

            HttpCookie cookie = new HttpCookie("PatientData");
            cookie["FullName"] = Server.UrlEncode(txtFullName.Text);
            cookie["NationalID"] = Server.UrlEncode(txtNationalId.Text);
            cookie["Phone"] = Server.UrlEncode(txtPhone.Text);
            cookie.Expires = DateTime.Now.AddMinutes(10);
            Response.Cookies.Add(cookie);

            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            int patientId;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand checkPatient = new SqlCommand("SELECT PatientID FROM Patients WHERE NationalID = @NationalID", conn);
                checkPatient.Parameters.AddWithValue("@NationalID", nationalId);
                var result = checkPatient.ExecuteScalar();

                if (result != null)
                {
                    patientId = Convert.ToInt32(result);
                }
                else
                {
                    SqlCommand insertPatient = new SqlCommand(@"
                        INSERT INTO Patients (FullName, NationalID, Phone)
                        OUTPUT INSERTED.PatientID
                        VALUES (@Name, @NationalID, @Phone)", conn);

                    insertPatient.Parameters.AddWithValue("@Name", name);
                    insertPatient.Parameters.AddWithValue("@NationalID", nationalId);
                    insertPatient.Parameters.AddWithValue("@Phone", phone);

                    patientId = (int)insertPatient.ExecuteScalar();
                }

                SqlCommand insertRequest = new SqlCommand(@"
                    INSERT INTO TestRequests (PatientID, TestName, TestDate, IsProcessed, RequestedAt)
                    VALUES (@PatientID, N'طلب فحص من المريض', GETDATE(), 0, GETDATE())", conn);
                insertRequest.Parameters.AddWithValue("@PatientID", patientId);
                insertRequest.ExecuteNonQuery();
            }

            lblWelcome.Text = $"مرحباً {name} 👋";
            lblWelcome.Visible = true;
            ShowMessage("✅ تم إرسال طلب الفحص بنجاح.", "alert-success");

            ScriptManager.RegisterStartupScript(this, GetType(), "showToast", "showSuccessToast();", true);

            gridResults.Visible = false;
        }

        protected void btnCheckResults_Click(object sender, EventArgs e)
        {
            string nationalId = txtResultNationalId.Text.Trim();

            if (string.IsNullOrEmpty(nationalId) || !Regex.IsMatch(nationalId, @"^\d{9}$"))
            {
                ShowMessage("⚠️ رقم الهوية غير صالح. يجب أن يتكون من 9 أرقام فقط.", "alert-danger");
                ScriptManager.RegisterStartupScript(this, GetType(), "vibrate", "if(navigator.vibrate) navigator.vibrate(200); playAlertSound();", true);
                return;
            }
            string connStr = ConfigurationManager.ConnectionStrings["LabResultsConnection"].ConnectionString;
            string query = @"
                SELECT P.FullName AS PatientName, T.RequestedAt, T.ProcessedAt,T.LabNote, T.UploadedFilePath, T.IsProcessed
                FROM TestRequests T
                INNER JOIN Patients P ON T.PatientID = P.PatientID
                WHERE P.NationalID = @NationalID
                ORDER BY T.RequestedAt DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@NationalID", nationalId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                ResultData = new DataTable();
                da.Fill(ResultData);

                string baseUrl = $"{Request.Url.Scheme}://{Request.Url.Authority}{ResolveUrl("~")}";
                string patientName = Session["PatientName"] != null ? Session["PatientName"].ToString() : "المريض";

                foreach (DataRow row in ResultData.Rows)
                {
                    if (row["UploadedFilePath"] != DBNull.Value)
                    {
                        string relativePath = row["UploadedFilePath"].ToString().TrimStart('~', '/');
                        string encrypted = Convert.ToBase64String(Encoding.UTF8.GetBytes(relativePath));
                        string secureUrl = baseUrl + "RedirectHandler.ashx?id=" + encrypted;

                        string message = $"مرحباً {patientName} بك في مختبر ابن سينا\nنتيجة الفحص: {secureUrl}";
                        row["UploadedFilePath"] = secureUrl + "|" + HttpUtility.UrlEncode(message);
                    }
                }

                gridResults.DataSource = ResultData;
                gridResults.DataBind();
                gridResults.Visible = true;

                if (ResultData.Rows.Count == 0)
                {
                    ShowMessage("❌ لا توجد نتائج مرتبطة بهذا الرقم.", "alert-warning");
                }
                else
                {
                    ShowMessage($"✅ تم العثور على {ResultData.Rows.Count} نتيجة.", "alert-info");
                }
            }
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert {cssClass} d-block mt-3";
            ScriptManager.RegisterStartupScript(this, GetType(), "scrollToMessage", "document.getElementById('lblMessage').scrollIntoView({behavior: 'smooth'});", true);
        }
    }
}
