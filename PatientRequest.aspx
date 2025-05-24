<%@ Page Title="طلب فحص" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientRequest.aspx.cs" Inherits="LabResultSystem.PatientRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    طلب فحص
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="mb-4 text-center">طلب فحص مخبري</h3>

    <div class="mb-3">
        <label for="txtName">الاسم الكامل</label>
        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="أدخل اسمك الكامل" />
    </div>

    <div class="mb-3">
        <label for="txtNationalId">رقم الهوية</label>
        <asp:TextBox ID="txtNationalId" runat="server" CssClass="form-control" placeholder="أدخل رقم الهوية" />
    </div>

    <div class="mb-3">
        <label for="txtPhone">رقم الهاتف</label>
        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="أدخل رقم الهاتف" />
    </div>

    <div class="mb-3">
        <label for="txtEmail">البريد الإلكتروني</label>
        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="أدخل البريد الإلكتروني" TextMode="Email" />
    </div>

    <asp:Button ID="btnSubmit" runat="server" Text="طلب الفحص" CssClass="btn btn-primary w-100" OnClick="btnSubmit_Click" />

    <asp:Label ID="lblMessage" runat="server" CssClass="form-text mt-3" />
</asp:Content>
