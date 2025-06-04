<html>
<head>
    <title>Customer Login</title>
</head>
<body>
    <h2>Customer Login</h2>
    <form action="custLogin" method="post">
        <label>Username:</label>
        <input type="text" name="username" required><br>

        <label>Password:</label>
        <input type="password" name="password" required><br>

        <input type="submit" value="Login">

        <% if (request.getAttribute("errorMessage") != null) { %>
            <p style="color: red;"><%= request.getAttribute("errorMessage") %></p>
        <% } %>
    </form>
</body>
</html>
