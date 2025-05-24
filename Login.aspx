<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LabResultSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="rtl" lang="ar">
<head runat="server">
    <title>تسجيل الدخول</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        body {
            background: linear-gradient(to bottom right, #00bcd4, #004d60);
            font-family: 'Cairo', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            max-width: 400px;
            width: 100%;
            animation: fadeInUp 0.8s ease;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-card h3 {
            color: #004d60;
            font-weight: bold;
            margin-bottom: 20px;
        }

        .form-control {
            border-radius: 10px;
        }

        .btn-primary {
            background-color: #00a5b5;
            border: none;
            border-radius: 10px;
            font-weight: bold;
        }

        .btn-primary:hover {
            background-color: #007d8a;
        }

        .input-group-text {
            background-color: #e9ecef;
            border-radius: 0 10px 10px 0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-card">
            <h3 class="text-center"><i class="bi bi-person-lock"></i> تسجيل دخول الموظف</h3>

            <div class="mb-3">
                <label for="txtUsername" class="form-label">اسم المستخدم</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person-fill"></i></span>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                </div>
            </div>

            <div class="mb-3">
                <label for="txtPassword" class="form-label">كلمة المرور</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="🔐 دخول" CssClass="btn btn-primary w-100 mt-2" OnClick="btnLogin_Click" />
            <asp:Label ID="lblMessage" runat="server" CssClass="text-danger mt-3 d-block text-center" />
        </div>
    </form>
</body>
</html>