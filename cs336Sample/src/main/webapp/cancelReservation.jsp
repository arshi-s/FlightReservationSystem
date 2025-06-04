<%@ page import="java.sql.*" %>
<%
	String custID = request.getParameter("cust_id");
	if (custID == null) custID = request.getParameter("custID");

    String cancelStatus = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Cancel Reservation</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>Cancel Reservation for Customer ID: <%= custID %></h2>
    <p>Canceling one leg of a round-trip cancels the full reservation</p>


    <% if ("denied".equals(cancelStatus)) { %>
        <p style="color:red; font-weight:bold;">Economy class tickets cannot be canceled.</p>
    <% } else if ("success".equals(cancelStatus)) { %>
        <p style="color:green; font-weight:bold;">Reservation successfully canceled.</p>
    <% } else if ("alerted".equals(cancelStatus)) { %>
        <p style="color:green; font-weight:bold;">Reservation canceled. A customer on the waiting list has been alerted.</p>
    <% } %>

    <form method="post" action="cancelReservation">
        <input type="hidden" name="cust_id" value="<%= custID %>">
        <table>
            <tr>
                <th>Select</th>
                <th>Ticket ID</th>
                <th>Class</th>
                <th>Total Fare</th>
                <th>Purchase Date</th>
                <th>Flight #</th>
                <th>Airline</th>
                <th>Departure Date</th>
            </tr>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT FT.ticketID, FT.class, FT.totalfare, FT.purchasedate, " +
                        "FTF.flight_number, FTF.airline_id, FTF.departure_date " +
                        "FROM FlightTicket FT JOIN FlightTicketFlights FTF ON FT.ticketID = FTF.ticketID " +
                        "WHERE FT.custID = ?"
                    );
                    stmt.setInt(1, Integer.parseInt(custID));
                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        int ticketID = rs.getInt("ticketID");
                        String tClass = rs.getString("class");
                        int fare = rs.getInt("totalfare");
                        Date pDate = rs.getDate("purchasedate");
                        int fNum = rs.getInt("flight_number");
                        String airline = rs.getString("airline_id");
                        Date dDate = rs.getDate("departure_date");
            %>
            <tr>
                <td><input type="radio" name="ticketID" value="<%= ticketID %>" required></td>
                <td><%= ticketID %></td>
                <td><%= tClass %></td>
                <td>$<%= fare %></td>
                <td><%= pDate %></td>
                <td><%= fNum %></td>
                <td><%= airline %></td>
                <td><%= dDate %></td>
            </tr>
            <% 
                    }
                    conn.close();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error loading reservations: " + e.getMessage() + "</p>");
                }
            %>
        </table>
        <br>
        <input type="submit" value="Cancel Reservation">
    </form>

    <br>
    <a href="homeCustomer.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px;">Home</a>
</body>
</html>
