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
    String flightNumber = request.getParameter("flight_number");
    String customerName = request.getParameter("customer_name");

    ResultSet rs = null;
    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

        String sql = "SELECT t.ticketid, u.fname AS customer_firstname, u.lname AS customer_lastname, " +
                     "u.fname as passenger_firstname, u.lname as passenger_lastname, f.flight_number, a.airline_name, " +
                     "t.class, t.totalfare, t.bookingfee, t.purchasedate " +
                     "FROM flightTicket t " +
                     "JOIN customer u ON t.custid = u.custid " +
                     "LEFT JOIN flightTicketFlights tfa ON t.ticketid = tfa.ticketid " +
                     "LEFT JOIN Flights f ON tfa.flight_number = f.flight_number " +
                     "LEFT JOIN Airline a ON f.airline_id = a.airline_id ";

        boolean hasFlight = flightNumber != null && !flightNumber.trim().isEmpty();
        boolean hasCustomer = customerName != null && !customerName.trim().isEmpty();

        if (hasFlight || hasCustomer) {
            sql += "WHERE ";
            if (hasFlight) {
                sql += "f.flight_number = ? ";
            }
            if (hasFlight && hasCustomer) {
                sql += "AND ";
            }
            if (hasCustomer) {
                sql += "CONCAT(u.fname, ' ', u.lname) LIKE ? ";
            }
        }

        stmt = conn.prepareStatement(sql);

        // Set parameters based on which fields are used
        int paramIndex = 1;
        if (hasFlight) {
            stmt.setString(paramIndex++, flightNumber);
        }
        if (hasCustomer) {
            stmt.setString(paramIndex++, "%" + customerName + "%");
        }

        rs = stmt.executeQuery();
%>

<!-- HTML Form and Table -->
<!DOCTYPE html>
<html>
<head><title>Reservations Report</title></head>
<body>
<a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
<h2>Reservations Report</h2>
<form method="get" action="">
    Flight Number: <input type="text" name="flight_number" value="<%= flightNumber != null ? flightNumber : "" %>"><br>
    Customer Name: <input type="text" name="customer_name" value="<%= customerName != null ? customerName : "" %>"><br>
    <input type="submit" value="Search">
</form>

<table border="1">
    <tr>
        <th>Ticket ID</th>
        <th>Customer Name</th>
        <th>Passenger Name</th>
        <th>Flight Number</th>
        <th>Airline</th>
        <th>Class</th>
        <th>Total Fare</th>
        <th>Booking Fee</th>
        <th>Purchase Date</th>
    </tr>
<%
        while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("ticketid") %></td>
        <td><%= rs.getString("customer_firstname") + " " + rs.getString("customer_lastname") %></td>
        <td><%= rs.getString("passenger_firstname") + " " + rs.getString("passenger_lastname") %></td>
        <td><%= rs.getString("flight_number") != null ? rs.getString("flight_number") : "N/A" %></td>
        <td><%= rs.getString("airline_name") != null ? rs.getString("airline_name") : "N/A" %></td>
        <td><%= rs.getString("class") %></td>
        <td><%= rs.getDouble("totalfare") %></td>
        <td><%= rs.getDouble("bookingfee") %></td>
        <td><%= rs.getTimestamp("purchasedate") %></td>
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