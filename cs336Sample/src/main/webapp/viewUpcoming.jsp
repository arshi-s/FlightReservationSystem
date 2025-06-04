<%@ page import="java.sql.*" %>
<%
    ResultSet rs = (ResultSet) request.getAttribute("results");
String custID = request.getParameter("cust_id");

%>
<h2>Upcoming Flight Reservations</h2>
<table border="1">
    <tr>
        <th>Ticket ID</th>
        <th>Purchase Date</th>
        <th>Airline</th>
        <th>Flight #</th>
        <th>From</th>
        <th>To</th>
        <th>Departure Date</th>
    </tr>
<%
    while (rs != null && rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("ticketID") %></td>
        <td><%= rs.getDate("purchasedate") %></td>
        <td><%= rs.getString("airline_id") %></td>
        <td><%= rs.getInt("flight_number") %></td>
        <td><%= rs.getString("depart_airportID") %></td>
        <td><%= rs.getString("arrival_airportID") %></td>
        <td><%= rs.getDate("departure_date") %></td>
    </tr>
<%
    }
%>
</table>

<a href="homeCustomer.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px; font-weight:bold;">Home</a>
