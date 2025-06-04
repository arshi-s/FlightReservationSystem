<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*,java.util.*,java.sql.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>

<%
    // Check if the user is logged in and has the 'admin' role
    //String userRole = (String) session.getAttribute("userRole");
    String userRole = "admin"; 
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
%>

<%
Connection conn = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    String sql = "SELECT " +
                 "u.custID, u.fname, u.lname, " +
                 "COUNT(t.ticketID) AS tickets_purchased, " +
                 "SUM(t.totalfare + t.bookingfee) AS total_revenue " +
                 "FROM flightticket t " +
                 "JOIN customer u ON t.custid = u.custid " +
                 "GROUP BY u.custid, u.fname, u.lname " +
                 "ORDER BY total_revenue DESC " +
                 "LIMIT 1";

    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Top Customer by Revenue</title>
</head>
<body>
<a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
<h2>Top Customer by Total Revenue</h2>
<table border="1">
    <tr>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Tickets Purchased</th>
        <th>Total Revenue (€)</th>
    </tr>
    <%
        if (rs.next()) {
    %>
    <tr>
        <td><%= rs.getString("fname") %></td>
        <td><%= rs.getString("lname") %></td>
        <td><%= rs.getInt("tickets_purchased") %></td>
        <td><%= rs.getDouble("total_revenue") %></td>
    </tr>
    <%
        } else {
    %>
    <tr><td colspan="4">No customer data found.</td></tr>
    <%
        }
    %>
</table>
</body>
</html>
<%
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    if (rs != null) try { rs.close(); } catch (Exception ignored) {}
    if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
}
%>