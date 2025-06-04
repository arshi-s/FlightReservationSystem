<%@ page import="java.sql.*" %>
<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String userId = request.getParameter("user_id");
        String role = request.getParameter("role");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            if ("customer".equals(role)) {
                // Check foreign key dependencies
                stmt = conn.prepareStatement("SELECT * FROM flightticket WHERE custID = ? UNION SELECT * FROM inquiry WHERE custID = ? UNION SELECT * FROM waitinglist WHERE custID = ?");
                stmt.setInt(1, Integer.parseInt(userId));
                stmt.setInt(2, Integer.parseInt(userId));
                stmt.setInt(3, Integer.parseInt(userId));
                rs = stmt.executeQuery();

                if (rs.next()) {
                    message = "Cannot delete customer. Active references in other tables.";
                } else {
                    // Delete from customeraccount first (foreign key)
                    stmt = conn.prepareStatement("DELETE FROM customeraccount WHERE custID = ?");
                    stmt.setInt(1, Integer.parseInt(userId));
                    stmt.executeUpdate();

                    // Delete from customer
                    stmt = conn.prepareStatement("DELETE FROM customer WHERE custID = ?");
                    stmt.setInt(1, Integer.parseInt(userId));
                    stmt.executeUpdate();

                    message = "Customer deleted successfully.";
                }
            } else if ("customer_rep".equals(role)) {
                // Check foreign key dependencies
                stmt = conn.prepareStatement("SELECT * FROM inquiry WHERE repID = ?");
                stmt.setInt(1, Integer.parseInt(userId));
                rs = stmt.executeQuery();

                if (rs.next()) {
                    message = "Cannot delete customer representative. Active references in inquiry table.";
                } else {
                    stmt = conn.prepareStatement("DELETE FROM customerrep WHERE repID = ?");
                    stmt.setInt(1, Integer.parseInt(userId));
                    stmt.executeUpdate();

                    message = "Customer Representative deleted successfully.";
                }
            } else if ("admin".equals(role)) {
                stmt = conn.prepareStatement("DELETE FROM admin WHERE adminID = ?");
                stmt.setInt(1, Integer.parseInt(userId));
                stmt.executeUpdate();

                message = "Admin deleted successfully.";
            }
        } catch (Exception e) {
            message = "Error deleting user: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<h3>Delete User</h3>
<form method="post">
    <label for="user_id">User ID:</label>
    <input type="text" name="user_id" required><br><br>

    <label for="role">Role:</label>
    <select name="role" required>
        <option value="customer">Customer</option>
        <option value="customer_rep">Customer Rep</option>
    </select><br><br>

    <input type="submit" value="Delete User" onclick="return confirm('Are you sure you want to delete this user?');">
</form>

<% if (!message.isEmpty()) { %>
    <p><%= message %></p>
<% } %>


