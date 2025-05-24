
<%@ Page Title="بوابة المريض" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="PatientPortal.aspx.cs" Inherits="LabResultSystem.PatientPortal" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    بوابة المريض
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        body {
            font-family: 'Cairo', sans-serif;
        }

        .hero-modern {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap-reverse;
            padding: 40px 20px;
            background-color: white;
            border-radius: 16px;
            margin-bottom: 40px;
            gap: 40px;
        }

        .hero-modern img {
            max-width: 560px;
            width: 100%;
            margin-right: 50px;
        }

        .hero-text {
            max-width: 500px;
            flex: 1;
            direction: rtl;
        }

        .hero-text h1 {
            color: #00a5b5;
            font-size: 2.6rem;
            font-weight: bold;
            margin-bottom: 15px;
            text-align: center;
            opacity: 0;
            animation: slideInRightToLeft 1s ease-out forwards;
            animation-delay: 0.2s;
        }

        .hero-text p {
            font-size: 1.3rem;
            color: #333;
            text-align: center;
            opacity: 0;
            animation: slideInRightToLeft 1s ease-out forwards;
            animation-delay: 0.6s;
        }

        @keyframes slideInRightToLeft {
            0% {
                opacity: 0;
                transform: translateX(50px);
            }
            100% {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .btn-main {
            background-color: #00a5b5;
            color: white;
            border: none;
            font-size: 18px;
            padding: 12px;
            border-radius: 8px;
            transition: transform 0.2s, box-shadow 0.3s;
        }

        .btn-main:hover {
            background-color: #008c9a;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .btn-dark-main {
            background-color: #004750;
            color: white;
            border: none;
            font-size: 18px;
            padding: 12px;
            border-radius: 8px;
            transition: transform 0.2s, box-shadow 0.3s;
        }

        .btn-dark-main:hover {
            background-color: #002f33;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .card-header-custom {
            background-color: #004750;
            color: white;
        }

        .form-control {
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        footer {
            text-align: center;
            padding: 20px;
            color: #777;
            font-size: 14px;
        }

        .toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            min-width: 250px;
            z-index: 1050;
        }
    </style>

    <div class="hero-modern">
        <div class="hero-text text-end">
            <h1>🔬 مختبر مستشفى ابن سينا</h1>
            <p>صحتك أولويتنا… تابع نتائجك بكل راحة وأمان.</p>
        </div>
        <img src="https://i.imgur.com/cYRrNP9.jpeg" alt="مختبر ابن سينا" />
    </div>

    <div class="container">
        <div class="card shadow-lg">
            <div class="card-header card-header-custom text-center">
                <h3 class="mb-0">📂 إدارة الفحوصات</h3>
            </div>
            <div class="card-body">

                <asp:Label ID="lblWelcome" runat="server" CssClass="alert alert-success text-center" Visible="false" />

                <div class="d-flex gap-3 mb-4 justify-content-center">
                    <asp:Button ID="btnShowRequestForm" runat="server" Text="🧪 طلب فحص" CssClass="btn btn-main w-50" OnClick="btnShowRequestForm_Click" />
                    <asp:Button ID="btnShowResultsForm" runat="server" Text="📄 عرض النتائج" CssClass="btn btn-dark-main w-50" OnClick="btnShowResultsForm_Click" />
                </div>

                <asp:Panel ID="panelRequestForm" runat="server" Visible="false">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtFullName">الاسم الكامل <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="txtNationalId">رقم الهوية <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtNationalId" runat="server" CssClass="form-control" MaxLength="9" />
                        </div>
                    </div>
                    <div class="mb-3">
<label>رقم الهاتف (Whatsapp)</label>
<div class="input-group">
    <asp:TextBox ID="txtPhone" runat="server"
        CssClass="form-control text-start"
        placeholder="مثلاً: 592345678"
        MaxLength="9" />
    
    <span class="input-group-text bg-light">
        +
        <asp:DropDownList ID="ddlPhonePrefix" runat="server" CssClass="form-select border-0 bg-transparent">
            <asp:ListItem Text="970" Value="970" />
            <asp:ListItem Text="972" Value="972" />
        </asp:DropDownList>
    </span>
</div>

<asp:Label ID="Label1" runat="server" CssClass="text-danger small" Visible="false" />

<asp:Label ID="lblPhoneError" runat="server" CssClass="text-danger small" Visible="false" />
                    </div>
                    <asp:Button ID="btnRequestTest" runat="server" Text="📨 إرسال الطلب" CssClass="btn btn-main w-100 mb-2" OnClick="btnRequestTest_Click" />
                </asp:Panel>

                <asp:Panel ID="panelResultsForm" runat="server" Visible="false">
                    <div class="mb-3">
                        <label for="txtResultNationalId">رقم الهوية <span class="text-danger">*</span></label>
<asp:TextBox ID="txtResultNationalId" runat="server"
    CssClass="form-control"
    MaxLength="9"
    pattern="\d{9}"
    title="رقم الهوية يجب أن يتكون من 9 أرقام" />                    </div>
                    <asp:Button ID="btnCheckResults" runat="server" Text="🔍 بحث" CssClass="btn btn-dark-main w-100" OnClick="btnCheckResults_Click" />
                </asp:Panel>

                <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block mt-3" />

                <asp:GridView ID="gridResults" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered mt-4 text-center" Visible="false">
                    <Columns>
<asp:BoundField DataField="PatientName" HeaderText="اسم المريض" />
                        <asp:BoundField DataField="RequestedAt" HeaderText="تاريخ الطلب" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                        <asp:BoundField DataField="ProcessedAt" HeaderText="تاريخ التسليم" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                        <asp:TemplateField HeaderText="الحالة">
                            <ItemTemplate>
                                <%# Eval("IsProcessed").ToString() == "True"
                                    ? "<div class='progress'><div class='progress-bar bg-success' style='width:100%'>مكتمل</div></div>"
                                    : "<div class='progress'><div class='progress-bar bg-warning' style='width:50%'>قيد المعالجة</div></div>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                     <asp:BoundField DataField="LabNote" HeaderText="ملاحظات" />
<asp:TemplateField HeaderText="النتيجة">
    <ItemTemplate>
        <%# Eval("IsProcessed").ToString() == "True"
            ? $@"<div class='d-flex flex-column align-items-center gap-2'>
                    <a class='btn btn-outline-primary btn-sm' href='{Eval("UploadedFilePath").ToString().Split('|')[0]}' target='_blank'>📄 تحميل النتيجة</a>
                    <button type='button' class='btn btn-outline-secondary btn-sm' onclick=""window.open('{Eval("UploadedFilePath").ToString().Split('|')[0]}', '_blank')"">📄 عرض النتيجة</button>
                    <a class='btn btn-outline-success btn-sm' target='_blank'
                       href='https://wa.me/?text={Eval("UploadedFilePath").ToString().Split('|')[1]}'>📤 مشاركة عبر الواتس اب</a>
                    <img src='https://api.qrserver.com/v1/create-qr-code/?size=100x100&data={Eval("UploadedFilePath").ToString().Split('|')[0]}' alt='QR Code' title='رمز QR للنتيجة'/>
               </div>"
            : "<span class='text-muted'>قيد الانتظار</span>" %>
    </ItemTemplate>
</asp:TemplateField>


                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="toast align-items-center text-white bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true" id="successToast">
        <div class="d-flex">
            <div class="toast-body">
                ✅ تم تنفيذ الإجراء بنجاح
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>

    <script>
        function showSuccessToast() {
            var toastEl = document.getElementById('successToast');
            var toast = new bootstrap.Toast(toastEl);
            toast.show();
        }
    </script>

    <footer>
        جميع الحقوق محفوظة © مختبر ابن سينا 2025
    </footer>


    <audio id="alertSound" src="https://www.soundjay.com/buttons/sounds/button-10.mp3" preload="auto"></audio>
<script>
    function playAlertSound() {
        const sound = document.getElementById('alertSound');
        if (sound) sound.play();
    }
</script>


</asp:Content>