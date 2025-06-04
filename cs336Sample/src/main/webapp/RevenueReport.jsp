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
String reportType = request.getParameter("reportType");
String flightNumber = request.getParameter("flightNumber");
String airlineName = request.getParameter("airlineName");
String firstname = request.getParameter("firstname");
String lastname = request.getParameter("lastname");

ResultSet rs = null;
Connection conn = null;
PreparedStatement stmt = null;

String query = "";
boolean showResults = false;

try {
    Class.forName("com.mysql.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    if ("flight".equals(reportType) && flightNumber != null && !flightNumber.isEmpty()) {
        query = "SELECT f.flight_number, COUNT(t.ticketid) AS total_tickets_sold, " +
                "SUM(t.totalfare + t.bookingfee) AS total_revenue " +
                "FROM flightticket t " +
                "JOIN Flightticketflights tfa ON t.ticketid = tfa.ticketid " +
                "JOIN Flights f ON tfa.flight_number = f.flight_number " +
                "WHERE f.flight_number = ? GROUP BY f.flight_number";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, flightNumber);
        showResults = true;
    } else if ("airline".equals(reportType) && airlineName != null && !airlineName.isEmpty()) {
        query = "SELECT a.airline_name, COUNT(t.ticketid) AS total_tickets_sold, " +
                "SUM(t.totalfare) AS total_fare_revenue, " +
                "SUM(t.bookingfee) AS total_booking_fees, " +
                "SUM(t.totalfare + t.bookingfee) AS total_revenue " +
                "FROM flightTicket t " +
                "JOIN flightTicketFlights tfa ON t.ticketid = tfa.ticketid " +
                "JOIN Flights f ON tfa.flight_number = f.flight_number " +
                "JOIN Airline a ON f.airline_id = a.airline_id " +
                "WHERE a.airline_name = ? GROUP BY a.airline_name";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, airlineName);
        showResults = true;
    } else if ("customer".equals(reportType) && firstname != null && lastname != null && !firstname.isEmpty() && !lastname.isEmpty()) {
        query = "SELECT u.fname, u.lname, COUNT(t.ticketid) AS total_tickets_purchased, " +
                "SUM(t.totalfare) AS total_fare_spent, " +
                "SUM(t.bookingfee) AS total_booking_fees, " +
                "SUM(t.totalfare + t.bookingfee) AS total_revenue_contributed " +
                "FROM flightTicket t " +
                "JOIN customer u ON t.custid = u.custid " +
                "WHERE u.fname = ? AND u.lname = ? " +
                "GROUP BY u.custid, u.fname, u.lname";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, firstname);
        stmt.setString(2, lastname);
        showResults = true;
    }

    if (stmt != null) {
        rs = stmt.executeQuery();
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Revenue Report</title>
</head>
<body>
<a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
<h2>Generate Revenue Report</h2>
<form method="get" action="RevenueReport.jsp">
    <label>Select Report Type:</label>
    <select name="reportType" onchange="this.form.submit()">
        <option value="">-- Select --</option>
        <option value="flight" <%= "flight".equals(reportType) ? "selected" : "" %>>By Flight</option>
        <option value="airline" <%= "airline".equals(reportType) ? "selected" : "" %>>By Airline</option>
        <option value="customer" <%= "customer".equals(reportType) ? "selected" : "" %>>By Customer</option>
    </select><br><br>

    <% if ("flight".equals(reportType)) { %>
        Flight Number: <input type="text" name="flightNumber" value="<%= flightNumber != null ? flightNumber : "" %>" />
        <input type="submit" value="Generate Report" />
    <% } else if ("airline".equals(reportType)) { %>
        Airline Name: <input type="text" name="airlineName" value="<%= airlineName != null ? airlineName : "" %>" />
        <input type="submit" value="Generate Report" />
    <% } else if ("customer".equals(reportType)) { %>
        First Name: <input type="text" name="firstname" value="<%= firstname != null ? firstname : "" %>" />
        Last Name: <input type="text" name="lastname" value="<%= lastname != null ? lastname : "" %>" />
        <input type="submit" value="Generate Report" />
    <% } %>
</form>

<hr>

<% if (showResults && rs != null && rs.next()) { %>
    <h3>Revenue Report:</h3>
    <table border="1">
        <tr>
            <% 
                ResultSetMetaData meta = rs.getMetaData();
                int columnCount = meta.getColumnCount();
                for (int i = 1; i <= columnCount; i++) {
            %>
            <th><%= meta.getColumnLabel(i) %></th>
            <% } %>
        </tr>
        <% do { %>
            <tr>
            <% for (int i = 1; i <= columnCount; i++) { %>
                <td><%= rs.getString(i) %></td>
            <% } %>
            </tr>
        <% } while (rs.next()); %>
    </table>
<% } else if (showResults) { %>
    <p><strong>No data found for the selected criteria.</strong></p>
<% } %>

</body>
</html>

<%
} catch (Exception e) {
	out.println("Error: " + e.getMessage());
	e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    if (rs != null) rs.close();
    if (stmt != null) stmt.close();
    if (conn != null) conn.close();
}
%>