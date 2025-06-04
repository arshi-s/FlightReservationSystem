<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Representative Home</title>
</head>
<body>
    <h1>Welcome to the Flight Reservation System - Customer Representative Home</h1>
    <p>Your Rep ID: <%= session.getAttribute("repid") %></p>

<%
    // Get customer list from DB
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String selectedCustID = request.getParameter("custID");

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
        stmt = conn.prepareStatement("SELECT custID, fname, lname FROM customer");
        rs = stmt.executeQuery();
%>
    <form method="get" action="">
        <label for="custID">Select a Customer:</label>
        <select name="custID" id="custID" required>
            <option value="">-- Select Customer --</option>
<%
        while (rs.next()) {
            String custID = rs.getString("custID");
            String fname = rs.getString("fname");
            String lname = rs.getString("lname");
            boolean selected = custID.equals(selectedCustID);
%>
            <option value="<%= custID %>" <%= selected ? "selected" : "" %>>
                ID: <%= custID %> - <%= fname %> <%= lname %>
            </option>
<%
        }
%>
        </select>
        <input type="submit" value="Proceed">
    </form>
<%
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading customers: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

    <h3>General Operations</h3>
    <ul>
        <li><a href="maintainAircraft.jsp">Add-Upd-Del Aircraft</a></li>
        <li><a href="maintainAirport.jsp">Add-Upd-Del Airport</a></li>
        <li><a href="maintainFlight.jsp">Add-Upd-Del Flight</a></li>
        <li><a href="retrieveFlightWaitList.jsp">Retrieve Waiting List on a Flight</a></li>
        <li><a href="retrieveArrivalDepartures.jsp">Retrieve Arrivals and Departures</a></li>
    </ul>

<%
    if (selectedCustID != null && !selectedCustID.equals("")) {
%>
    <h3>Operations for Customer ID: <%= selectedCustID %></h3>
    <ul>
        <li><a href="searchFlightsRep.jsp?custID=<%= selectedCustID %>">Search Flights</a></li>
        <li><a href="cancelReservation.jsp?custID=<%= selectedCustID %>">Cancel Reservation</a></li>
        <li><a href="editReservation.jsp?custID=<%= selectedCustID %>">Edit Reservation</a></li>
        <li><a href="replyToQuestions.jsp?custID=<%= selectedCustID %>">Reply to Questions</a></li>
    </ul>
<%
    }
%>

	<a href="custRepLogin">Logout</a>
    <br><a href="home.jsp">Back to Main Home</a>

</body>
</html>

