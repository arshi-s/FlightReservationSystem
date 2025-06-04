<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*,java.util.*,java.sql.*" %>
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

<html>
<head>
    <title>Monthly Sales Report</title>
</head>
<body>
<a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
    <h2>Monthly Sales Report</h2>

    <form method="get" action="MonthlySalesReport.jsp">
        <label for="month">Month (1–12):</label>
        <input type="number" id="month" name="month" min="1" max="12" required>
        <br>
        <label for="year">Year (e.g., 2025):</label>
        <input type="number" id="year" name="year" min="2000" required>
        <br><br>
        <input type="submit" value="Generate Report">
    </form>

<%
    String monthParam = request.getParameter("month");
    String yearParam = request.getParameter("year");

    if (monthParam != null && yearParam != null) {
        int month = Integer.parseInt(monthParam);
        int year = Integer.parseInt(yearParam);

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            String sql = "SELECT COUNT(*) AS total_tickets, " +
                         "SUM(totalfare + bookingfee) AS total_revenue " +
                         "FROM flightticket " +
                         "WHERE MONTH(purchasedate) = ? AND YEAR(purchasedate) = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, month);
            stmt.setInt(2, year);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int totalTickets = rs.getInt("total_tickets");
                double totalRevenue = rs.getDouble("total_revenue");
%>
                <h3>Sales Report for <%= month %>/<%= year %></h3>
                <table border="1">
                    <tr>
                        <th>Total Tickets Sold</th>
                        <th>Total Revenue (€)</th>
                    </tr>
                    <tr>
                        <td><%= totalTickets %></td>
                        <td><%= String.format("%.2f", totalRevenue) %></td>
                    </tr>
                </table>
<%
            } else {
%>
                <p>No sales data found for this month/year.</p>
<%
            }
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>
</body>
</html>