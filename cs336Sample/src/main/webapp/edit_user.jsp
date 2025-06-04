<%@ page import="java.sql.*" %>
<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String userId = request.getParameter("user_id");
        String role = request.getParameter("role").toLowerCase();

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        Connection conn = null;
        PreparedStatement stmt1 = null;
        PreparedStatement stmt2 = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            int updated = 0;

            if ("customer".equals(role)) {
                // Update name in customer table
                String sql1 = "UPDATE customer SET fname = ?, lname = ? WHERE custID = ?";
                stmt1 = conn.prepareStatement(sql1);
                stmt1.setString(1, fname);
                stmt1.setString(2, lname);
                stmt1.setInt(3, Integer.parseInt(userId));
                updated += stmt1.executeUpdate();

                // Update account info in customeraccount table
                String sql2 = "UPDATE customeraccount SET username = ?, password = ? WHERE custID = ?";
                stmt2 = conn.prepareStatement(sql2);
                stmt2.setString(1, username);
                stmt2.setString(2, password);
                stmt2.setInt(3, Integer.parseInt(userId));
                updated += stmt2.executeUpdate();

            } else if ("customerrep".equals(role)) {
                String sql = "UPDATE customerrep SET fname = ?, lname = ?, username = ?, password = ?, email = ?, phoneNumber = ? WHERE repID = ?";
                stmt1 = conn.prepareStatement(sql);
                stmt1.setString(1, fname);
                stmt1.setString(2, lname);
                stmt1.setString(3, username);
                stmt1.setString(4, password);
                stmt1.setString(5, email);
                stmt1.setString(6, phone);
                stmt1.setInt(7, Integer.parseInt(userId));
                updated = stmt1.executeUpdate();

            } else if ("admin".equals(role)) {
                String sql = "UPDATE admin SET fname = ?, lname = ?, username = ?, password = ?, email = ?, phoneNumber = ? WHERE adminID = ?";
                stmt1 = conn.prepareStatement(sql);
                stmt1.setString(1, fname);
                stmt1.setString(2, lname);
                stmt1.setString(3, username);
                stmt1.setString(4, password);
                stmt1.setString(5, email);
                stmt1.setString(6, phone);
                stmt1.setInt(7, Integer.parseInt(userId));
                updated = stmt1.executeUpdate();
            }

            if (updated > 0) {
                message = "User updated successfully.";
            } else {
                message = "User not found or not updated.";
            }

        } catch (Exception e) {
            message = "Error updating user: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (stmt1 != null) stmt1.close();
            if (stmt2 != null) stmt2.close();
            if (conn != null) conn.close();
        }
    }
%>

<h3>Edit User</h3>
<form method="post">
    <label for="user_id">User ID:</label>
    <input type="text" name="user_id" required><br>

    <label for="role">Role:</label>
    <select name="role" required>
        <option value="customer">Customer</option>
        <option value="customerrep">Customer Rep</option>
    </select><br><br>

    <label for="fname">First Name:</label>
    <input type="text" name="fname" required><br>

    <label for="lname">Last Name:</label>
    <input type="text" name="lname" required><br>

    <label for="username">Username:</label>
    <input type="text" name="username" required><br>

    <label for="password">Password:</label>
    <input type="text" name="password" required><br>

    <label for="email">Email:</label>
    <input type="email" name="email"><br>

    <label for="phone">Phone Number:</label>
    <input type="text" name="phone"><br><br>

    <input type="submit" value="Update User">
</form>

<% if (!message.isEmpty()) { %>
    <p><%= message %></p>
<% } %>
    