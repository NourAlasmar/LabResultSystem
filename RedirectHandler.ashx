<%@ WebHandler Language="C#" Class="RedirectHandler" %>

using System;
using System.Text;
using System.Web;

public class RedirectHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string encrypted = context.Request.QueryString["id"];

        if (string.IsNullOrEmpty(encrypted))
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("❌ الرابط غير صالح.");
            return;
        }

        try
        {
            // فك التشفير من Base64
            string decodedPath = Encoding.UTF8.GetString(Convert.FromBase64String(encrypted));

            // تحقق من أن المسار يشير إلى PDF داخل مجلد Uploads
            if (!decodedPath.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase) || !decodedPath.StartsWith("Uploads/"))
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("⚠️ محاولة وصول غير مصرح بها.");
                return;
            }

            context.Response.Redirect("~/" + decodedPath, true);
        }
        catch
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("⚠️ فشل في قراءة الرابط المشفر.");
        }
    }

    public bool IsReusable => false;
}