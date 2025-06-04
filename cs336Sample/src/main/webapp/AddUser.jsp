<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        String email = request.getParameter("email");
        String role = request.getParameter("role");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            if ("customer".equals(role)) {
                // Retrieve last custID and increment
                stmt = conn.prepareStatement("SELECT MAX(custID) FROM customer");
                rs = stmt.executeQuery();
                int newCustID = (rs.next() ? rs.getInt(1) : 0) + 1;

                // Insert into Customer
                stmt = conn.prepareStatement("INSERT INTO customer (custID, fname, lname) VALUES (?, ?, ?)");
                stmt.setInt(1, newCustID);
                stmt.setString(2, firstname);
                stmt.setString(3, lastname);
                stmt.executeUpdate();

                // Insert into CustomerAccount
                stmt = conn.prepareStatement("INSERT INTO customeraccount (username, password, custID) VALUES (?, ?, ?)");
                stmt.setString(1, username);
                stmt.setString(2, password);
                stmt.setInt(3, newCustID);
                stmt.executeUpdate();

                message = "Customer added successfully!";
            } else if ("customer_rep".equals(role)) {
                // Insert into CustomerRep
                stmt = conn.prepareStatement("INSERT INTO customerrep (fname, lname, username, password, email) VALUES (?, ?, ?, ?, ?)");
                stmt.setString(1, firstname);
                stmt.setString(2, lastname);
                stmt.setString(3, username);
                stmt.setString(4, password);
                stmt.setString(5, email);
                stmt.executeUpdate();

                message = "Customer Representative added successfully!";
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New User</title>
</head>
<body>
    <h2>Add New User</h2>
    <form method="post">
        <label>Username: <input type="text" name="username" required></label><br><br>
        <label>Password: <input type="password" name="password" required></label><br><br>
        <label>First Name: <input type="text" name="firstname" required></label><br><br>
        <label>Last Name: <input type="text" name="lastname" required></label><br><br>
        <label>Email: <input type="email" name="email" required></label><br><br>
        <label>Role:
            <select name="role" required>
                <option value="customer">Customer</option>
                <option value="customer_rep">Customer Rep</option>
            </select>
        </label><br><br>
        <input type="submit" value="Add User">
    </form>
    <p style="color:red;"><%= message %></p>
    <a href="ManageUsers.jsp">Back to Manage Users</a>
</body>
</html>