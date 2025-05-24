<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="LabResultSystem.Home" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>الصفحة الرئيسية - الفحوصات</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container d-flex flex-column justify-content-center align-items-center min-vh-100">
            <div class="text-center mb-5">
                <h2>مرحبا بك في نظام الفحوصات</h2>
                <p class="lead">اختر أحد الخيارات التالية:</p>
            </div>

            <div class="row w-100 justify-content-center">
                <div class="col-12 col-md-5 mb-3">
                    <a href="CheckResults.aspx" class="btn btn-outline-primary w-100 py-3 fs-5">
                        🔍 معرفة نتيجة الفحص
                    </a>
                </div>
                <div class="col-12 col-md-5 mb-3">
                    <a href="PatientRequest.aspx" class="btn btn-outline-success w-100 py-3 fs-5">
                        📝 طلب فحص جديد
                    </a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>