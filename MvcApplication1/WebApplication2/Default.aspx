<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebApplication2._Default" %>


<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">

    <asp:Panel ID="Panel1" runat="server" Height="60px">
        <asp:Table ID="Table1" runat="server" CellPadding="3" class="table-bordered" Height="160px" HorizontalAlign="Left" Width="264px" ValidateRequestMode="Enabled">
        </asp:Table>
        <asp:Button ID="Button1" runat="server" class="btn btn-warning btn-lg" Height="56px" OnClick="click_event" Text="Solve" Width="131px" />
        <asp:Label ID="Label1" runat="server"></asp:Label>
        <asp:Button ID="Button2" runat="server" Height="56px" Text="Clear" Width="132px" OnClick="Button2_Click" class="btn btn-warning btn-lg"/>
    </asp:Panel>

</asp:Content>
