using System;
using System.Text;
using System.Web;

public partial class RedirectToFile : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string encrypted = Request.QueryString["id"];

        if (string.IsNullOrEmpty(encrypted))
        {
            Response.Write("❌ الرابط غير صالح.");
            return;
        }

        try
        {
            string decodedPath = Encoding.UTF8.GetString(Convert.FromBase64String(encrypted));

            // تحقق من المسار الآمن (اختياري: يمكن التحقق من امتدادات الملفات أو صلاحية المستخدم)
            if (!decodedPath.EndsWith(".pdf") || !decodedPath.StartsWith("Uploads/"))
            {
                Response.Write("⚠️ محاولة وصول غير مصرح بها.");
                return;
            }

            Response.Redirect("~/" + decodedPath, true);
        }
        catch
        {
            Response.Write("⚠️ فشل في قراءة الرابط المشفر.");
        }
    }
}
