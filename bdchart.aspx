<%@ Page Language="C#" %>

<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
    <title></title>    
</head>
    
<body style="background-color:darkcyan">
    <center> 
        
        <%  string namee = Request.Form["namee"];    %>
        <h1 style="color:crimson">יום הולדת שמח ל<%=namee %></h1>
        <%  string age = Request.Form["age"];    %>
        <h3 style="color:darkorange">מזל טוב ליום הולדתך ה-<%=age %></h3>
        <h3 style="color:greenyellow">שיהיו לך חיים מלאי בריאות ואהבה</h3>
        <%  string name = Request.Form["name"];    %>
        <h3 style="color:violet">מחברך הטוב - <%=name %></h3>
    </center>
</body>
    
</html>
