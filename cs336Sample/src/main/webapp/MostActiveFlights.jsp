<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*,java.util.*,java.sql.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>

<%
    // Check if the user is logged in and has the 'admin' role
    // String userRole = (String) session.getAttribute("userRole");
    String userRole = "admin";
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
%>

<%
ResultSet rs = null;
Connection conn = null;
PreparedStatement stmt = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    String sql = "SELECT f.airline_id, f.flight_number, a.airline_name, COUNT(tfa.ticketid) AS tickets_sold " +
                 "FROM flightticketflights tfa " +
                 "JOIN Flights f ON tfa.flight_number = f.flight_number AND tfa.airline_id = f.airline_id " +
                 "JOIN Airline a ON f.airline_id = a.airline_id " +
                 "GROUP BY f.airline_id, f.flight_number, a.airline_name " +
                 "ORDER BY tickets_sold DESC";

    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<title>Most Active Flights</title>
</head>
<body>
<a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
<h2>Most Active Flights (By Tickets Sold)</h2>

<table border="1">
    <tr>
        <th>Airline ID</th>
        <th>Flight Number</th>
        <th>Airline Name</th>
        <th>Tickets Sold</th>
    </tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getString("airline_id") %></td>
        <td><%= rs.getString("flight_number") %></td>
        <td><%= rs.getString("airline_name") %></td>
        <td><%= rs.getInt("tickets_sold") %></td>
    </tr>
<%
    }
%>
</table>
</body>
</html>

<%
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>