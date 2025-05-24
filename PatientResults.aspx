<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PatientResults.aspx.cs" Inherits="LabResultSystem.PatientResults" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>نتائج الفحوص</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server" class="container mt-5">
        <h3 class="mb-4">عرض نتائج الفحوص المخبرية</h3>

        <div class="mb-3">
            <label for="txtPatientId">رقم الهوية / الملف</label>
            <asp:TextBox ID="txtPatientId" runat="server" CssClass="form-control" />
        </div>

        <asp:Button ID="btnShowResults" runat="server" CssClass="btn btn-primary" Text="عرض النتائج" OnClick="btnShowResults_Click" />

        <asp:GridView ID="gridResults" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered mt-4" EmptyDataText="لا توجد نتائج متاحة.">
            <Columns>
                <asp:BoundField DataField="TestName" HeaderText="اسم الفحص" />
                <asp:BoundField DataField="TestDate" HeaderText="تاريخ الفحص" DataFormatString="{0:yyyy-MM-dd}" />
                <asp:TemplateField HeaderText="الملف">
                    <ItemTemplate>
                        <%# Eval("FilePath") != null && Eval("FilePath").ToString() != "" ?
                            $"<a class='btn btn-outline-primary' href='{Eval("FilePath")}' target='_blank'>تحميل</a>" :
                            "لم يتم الرفع" %>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <asp:Label ID="lblMessage" runat="server" CssClass="form-text mt-3 text-danger" />


    </form>
</body>
</html>