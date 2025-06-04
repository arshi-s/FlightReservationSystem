<!DOCTYPE html>
<html>
<head><title>Admin Login</title></head>
<body>
<h2>Admin Login</h2>
    <form action="adminLogin" method="post">
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>
    <c:if test="${param.error != null}">
        <p style="color:red;">${param.error}</p>
    </c:if>
</body>
</html>