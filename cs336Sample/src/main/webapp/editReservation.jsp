<%@ page import="java.sql.*" %>
<%
String custID = request.getParameter("cust_id");
if (custID == null) custID = request.getParameter("custID");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Reservation</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>

<h2>Edit Reservation for Customer ID: <%= custID %></h2>

<form method="get" action="searchFlightsRep.jsp">
    <input type="hidden" name="custID" value="<%= custID %>">

    <table>
        <tr>
            <th>Select</th>
            <th>Ticket ID</th>
            <th>Trip Type</th>
            <th>Class</th>
            <th>Total Fare</th>
            <th>Purchase Date</th>
            <th>Leg(s)</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

        // Get all tickets for this customer
        PreparedStatement ticketsStmt = conn.prepareStatement(
            "SELECT * FROM FlightTicket WHERE custID = ? ORDER BY ticketID"
        );
        ticketsStmt.setInt(1, Integer.parseInt(custID));
        ResultSet ticketsRs = ticketsStmt.executeQuery();

        while (ticketsRs.next()) {
            int ticketID = ticketsRs.getInt("ticketID");
            String tripType = ticketsRs.getString("triptype");
            String tClass = ticketsRs.getString("class");
            int fare = ticketsRs.getInt("totalfare");
            Date pDate = ticketsRs.getDate("purchasedate");

            // Fetch flight legs
            PreparedStatement legsStmt = conn.prepareStatement(
                "SELECT flight_number, airline_id, departure_date FROM FlightTicketFlights WHERE ticketID = ?"
            );
            legsStmt.setInt(1, ticketID);
            ResultSet legsRs = legsStmt.executeQuery();

            StringBuilder legsDisplay = new StringBuilder();
            while (legsRs.next()) {
                legsDisplay.append("[").append(legsRs.getString("airline_id"))
                           .append(" ").append(legsRs.getInt("flight_number"))
                           .append(" on ").append(legsRs.getString("departure_date")).append("] ");
            }

%>
        <tr>
            <td><input type="radio" name="original_ticket_id" value="<%= ticketID %>" required></td>
            <td><%= ticketID %></td>
            <td><%= tripType %></td>
            <td><%= tClass %></td>
            <td>$<%= fare %></td>
            <td><%= pDate %></td>
            <td><%= legsDisplay.toString() %></td>
        </tr>
<%
            legsRs.close();
            legsStmt.close();
        }

        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading reservations: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
%>
    </table>

    <br>
    <input type="submit" value="Edit This Reservation">
</form>

<br>
<a href="CustomerRepHome.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px;">Back to Home</a>

</body>
</html>
