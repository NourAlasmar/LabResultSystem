<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AllRequests.aspx.cs" Inherits="LabResultSystem.AllRequests" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" rel="stylesheet" />
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <title>كل الطلبات</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        body {
            font-family: 'Cairo', sans-serif;
            background-color: #f8f9fa;
        }
        h3 {
            color: #004750;
            font-weight: bold;
        }
        .form-label {
            font-weight: 600;
            color: #333;
        }
        .table thead th {
            background-color: #004750;
            color: white;
            vertical-align: middle;
            text-align: center;
        }
        .table td {
            vertical-align: middle;
            text-align: center;
        }
        .btn-primary {
            background-color: #00a5b5;
            border: none;
        }
        .btn-primary:hover {
            background-color: #008b97;
        }
        .badge {
            font-size: 0.9rem;
            padding: 0.5em 0.8em;
        }
        .input-group .form-control {
            border-radius: 0.5rem 0 0 0.5rem;
        }
        .input-group .btn {
            border-radius: 0 0.5rem 0.5rem 0;
        }
        .form-check-label {
            margin-right: 0.5rem;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="container mt-5">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <h3 class="mb-4 text-center border-bottom pb-2">📄 قائمة جميع طلبات الفحوصات</h3>

        <div class="row g-3 align-items-end mb-4">
            <div class="col-md-4">
                <label for="txtSearchName" class="form-label">اسم المريض</label>
                <asp:TextBox ID="txtSearchName" runat="server" CssClass="form-control" placeholder="مثلاً: أحمد" />
            </div>
            <div class="col-md-3">
                <label for="txtSearchDate" class="form-label">تاريخ الفحص</label>
                <asp:TextBox ID="txtSearchDate" runat="server" CssClass="form-control" TextMode="Date" />
            </div>
            <div class="col-md-3">
                <label for="ddlStatusFilter">الحالة</label>
                <div class="input-group">
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                        <asp:ListItem Text="الكل" Value="" />
                        <asp:ListItem Text="مسلمة" Value="true" />
                        <asp:ListItem Text="غير مسلمة" Value="false" />
                    </asp:DropDownList>
                    <asp:Button ID="Button1" runat="server" Text="🔍 بحث" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
        </div>

<asp:GridView ID="gridRequests" runat="server" AutoGenerateColumns="False"
    CssClass="table table-bordered" OnRowCommand="gridRequests_RowCommand">
    <Columns>
        <asp:BoundField DataField="FullName" HeaderText="اسم المريض" />
        <asp:BoundField DataField="NationalID" HeaderText="رقم الهوية" />
        <asp:BoundField DataField="Phone" HeaderText="رقم الهاتف" />
        <asp:BoundField DataField="RequestedAt" HeaderText="تاريخ الطلب" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
        <asp:BoundField DataField="ProcessedAt" HeaderText="تاريخ التسليم" DataFormatString="{0:yyyy-MM-dd HH:mm}" />

<asp:TemplateField HeaderText="النتيجة" ItemStyle-Width="350px">
    <ItemTemplate>
        <asp:Panel runat="server" Visible='<%# !(bool)Eval("IsProcessed") %>' CssClass="text-center">
            <div class="d-flex justify-content-center gap-2">
                <button type="button" class="btn btn-outline-success btn-sm"
                    onclick="openNoteModal('<%# Eval("RequestID") %>', 'upload')">
                    ⬆️ رفع
                </button>

                <button type="button" class="btn btn-outline-warning btn-sm"
                    onclick="openNoteModal('<%# Eval("RequestID") %>', 'note')">
                    📝 ملاحظة
                </button>
            </div>
        </asp:Panel>
        <asp:Panel runat="server" Visible='<%# (bool)Eval("IsProcessed") %>' CssClass="text-center">
            <div class="btn-group">
                <a class="btn btn-outline-primary btn-sm" href='<%# Eval("UploadedFilePath") %>' target="_blank">📄 تحميل</a>
            </div>
        </asp:Panel>
    </ItemTemplate>
</asp:TemplateField>

        <asp:TemplateField HeaderText="الملاحظة">
    <ItemTemplate>
        <%# Eval("LabNote").ToString() != "" 
            ? Eval("LabNote") 
            : "<span class='text-muted'></span>" %>
    </ItemTemplate>
</asp:TemplateField>

        <asp:TemplateField HeaderText="الحالة">
            <ItemTemplate>
                <%# Eval("IsProcessed").ToString() == "True" 
                    ? "<span class='badge bg-success'>مسلمة ✅</span>" 
                    : !string.IsNullOrEmpty(Eval("LabNote").ToString()) 
                        ? "<span class='badge bg-info text-dark'>ملاحظة 📝</span>" 
                        : "<span class='badge bg-warning text-dark'>غير مسلمة ⚠️</span>" %>
            </ItemTemplate>
        </asp:TemplateField>

<asp:TemplateField HeaderText="إجراءات">
    <ItemTemplate>
        <div class="d-flex justify-content-center gap-2">
            <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-success"
                CommandName="DuplicateRequest"
                CommandArgument='<%# Eval("RequestID") %>'
                ToolTip="إضافة فحص">
                <i class="bi bi-plus-lg"></i>
            </asp:LinkButton>

            <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger"
                CommandName="DeleteRequest"
                CommandArgument='<%# Eval("RequestID") %>'
                OnClientClick="return confirm('هل أنت متأكد من حذف هذا الطلب؟');"
                ToolTip="حذف الطلب">
                <i class="bi bi-x-lg"></i>
            </asp:LinkButton>
        </div>
    </ItemTemplate>
</asp:TemplateField>

    </Columns>
</asp:GridView>


<!-- نافذة الملاحظة الموحدة -->
<div class="modal fade" id="noteModal" tabindex="-1" aria-labelledby="noteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="noteModalLabel">📝 ملاحظة أو رفع نتيجة</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="إغلاق"></button>
            </div>

            <div class="modal-body">
                <!-- معرف الطلب المخفي -->
                <asp:HiddenField ID="HiddenField1" runat="server" />

                <!-- الملاحظة -->
                <div class="mb-3">
                    <label for="txtLabNote" class="form-label">الملاحظة</label>
<asp:TextBox ID="txtLabNote" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                </div>

                <!-- رفع ملف -->
                <div class="mb-3">
                    <label for="fileUploadModal" class="form-label">رفع نتيجة (PDF فقط)</label>
<asp:FileUpload ID="fileUploadModal" runat="server" CssClass="form-control" />
                </div>
            </div>

            <!-- الأزرار -->
            <div class="modal-footer d-flex justify-content-between">
                <!-- زر الملاحظة فقط -->
<asp:Button ID="btnSaveNote" runat="server"
    Text="💬 حفظ كملاحظة فقط"
    CssClass="btn btn-outline-info"
    OnClick="btnSaveNote_Click" />

                <!-- زر رفع النتيجة -->
                <asp:Button ID="btnUploadWithNote" runat="server"
                    Text="⬆️ رفع النتيجة"
                    CssClass="btn btn-success"
                    OnClick="btnSaveNote_Click" />
            </div>
        </div>
    </div>
</div>



        <asp:Label ID="lblMessage" runat="server" CssClass="text-danger mt-3" />
        <asp:HiddenField ID="hiddenRequestId" runat="server" />



<div class="toast align-items-center text-white bg-success border-0 position-fixed bottom-0 end-0 m-4"
     role="alert" aria-live="assertive" aria-atomic="true" id="uploadSuccessToast">
    <div class="d-flex">
        <div class="toast-body">
            ✅ تم رفع النتيجة أو حفظ الملاحظة بنجاح!
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="إغلاق"></button>
    </div>
</div>

<script type="text/javascript">
    function showUploadSuccessToast() {
        var toastEl = document.getElementById('uploadSuccessToast');
        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    }
</script>



    </form>

   <script type="text/javascript">
       function openNoteModal(requestId, action) {
           document.getElementById('<%= hiddenRequestId.ClientID %>').value = requestId;
            const uploadBtn = document.getElementById('<%= btnUploadWithNote.ClientID %>');
            const noteBtn = document.getElementById('<%= btnSaveNote.ClientID %>');
            const fileInput = document.getElementById('<%= fileUploadModal.ClientID %>');

           if (action === "upload") {
               uploadBtn.style.display = "inline-block";
               noteBtn.style.display = "none";
               fileInput.style.display = "block";
           } else {
               uploadBtn.style.display = "none";
               noteBtn.style.display = "inline-block";
               fileInput.style.display = "none";
           }

           var modal = new bootstrap.Modal(document.getElementById('noteModal'));
           modal.show();
       }

       function showUploadSuccessToast() {
           var toastEl = document.getElementById('uploadSuccessToast');
           var toast = new bootstrap.Toast(toastEl);
           toast.show();
       }
   </script>
</body>
</html>