<%@ Page Title="نتائج الفحص" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="CheckResults.aspx.cs" Inherits="LabResultSystem.CheckResults" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    نتائج الفحص
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="mb-4 text-center">الاستعلام عن نتائج الفحوصات</h3>

    <div class="mb-3">
        <label for="txtNationalId">رقم الهوية</label>
        <asp:TextBox ID="txtNationalId" runat="server" CssClass="form-control" placeholder="أدخل رقم الهوية" />
    </div>

    <asp:Button ID="btnSearch" runat="server" Text="عرض النتائج" CssClass="btn btn-primary w-100 mb-4" OnClick="btnSearch_Click" />

    <asp:GridView ID="gridResults" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered text-center" EmptyDataText="لا توجد نتائج حالياً.">
        <Columns>
            <asp:BoundField DataField="TestName" HeaderText="اسم الفحص" />
            <asp:BoundField DataField="RequestedAt" HeaderText="تاريخ الطلب" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            <asp:BoundField DataField="ProcessedAt" HeaderText="تاريخ التسليم" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            <asp:TemplateField HeaderText="النتيجة">
                <ItemTemplate>
                    <%# Eval("IsProcessed").ToString() == "True" ? $"<a class='btn btn-outline-primary' href='{Eval("UploadedFilePath")}' target='_blank'>تحميل</a>" : "قيد الانتظار" %>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:Label ID="lblMessage" runat="server" CssClass="form-text text-danger mt-3" />
</asp:Content>
