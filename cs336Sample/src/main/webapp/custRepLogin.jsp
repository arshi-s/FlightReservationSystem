<!DOCTYPE html>
<html>
<head>

	<title>Customer Representative Login</title>

</head>
<body>
<h2>Customer Reprentative Login</h2>
    <form action="custRepLogin" method="post">
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>
    <c:if test="${param.error != null}">
        <p style="color:red;">${param.error}</p>
    </c:if>
</body>
</html>