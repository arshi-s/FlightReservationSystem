<%@ page import="java.sql.*, java.time.*, java.time.format.*" %>
<%
    String custID = request.getParameter("cust_id");
    if (custID == null) {
        out.println("<p>Error: Missing customer ID.</p>");
        return;
    }

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
        );

        PreparedStatement ticketStmt = conn.prepareStatement(
            "SELECT ticketID FROM FlightTicket WHERE custID = ? ORDER BY purchasedate DESC, purchasetime DESC LIMIT 1"
        );
        ticketStmt.setInt(1, Integer.parseInt(custID));
        ResultSet ticketRs = ticketStmt.executeQuery();

        int ticketID = -1;
        if (ticketRs.next()) {
            ticketID = ticketRs.getInt("ticketID");
        }
        if (ticketID == -1) {
            out.println("<p>No ticket found for customer ID " + custID + ".</p>");
            return;
        }

        PreparedStatement summaryStmt = conn.prepareStatement(
            "SELECT * FROM FlightTicket WHERE ticketID = ?"
        );
        summaryStmt.setInt(1, ticketID);
        ResultSet summaryRs = summaryStmt.executeQuery();

        if (summaryRs.next()) {
            double totalFare = summaryRs.getDouble("totalfare");
            int bookingFee = summaryRs.getInt("bookingfee");
%>
<html>
<head>
    <title>Ticket Confirmation</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        h2 { color: green; }
        table { border-collapse: collapse; width: 95%; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
        th { background-color: #f2f2f2; }
        a.button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #007BFF;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 20px;
        }
    </style>
</head>
<body>

    <h2>Reservation Confirmed!</h2>
    <p><strong>Ticket ID:</strong> <%= ticketID %></p>
    <p><strong>Trip Type:</strong> <%= summaryRs.getString("triptype") %></p>
    <p><strong>Class:</strong> <%= summaryRs.getString("class") %></p>
    <p><strong>Purchase Date:</strong> <%= summaryRs.getDate("purchasedate") %></p>
    <p><strong>Purchase Time:</strong> <%= summaryRs.getTime("purchasetime") %></p>

    <h3>Fare Breakdown (Per Leg):</h3>
    <table>
        <tr>
            <th>Airline</th>
            <th>Flight #</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Departure Date</th>
            <th>Seat #</th>
            <th>Class</th>
            <th>Base Fare</th>
            <th>Adjusted Fare</th>
        </tr>
<%
        double fareSum = 0.0;

        PreparedStatement legsStmt = conn.prepareStatement(
            "SELECT FTF.airline_id, FTF.flight_number, FTF.departure_date, FTF.departure_time, FTF.seatnum, FTF.class, " +
            "F.depart_airportID, F.arrival_airportID, F.price " +
            "FROM FlightTicketFlights FTF " +
            "JOIN Flights F ON FTF.flight_number = F.flight_number AND FTF.airline_id = F.airline_id " +
            "WHERE FTF.ticketID = ?"
        );
        legsStmt.setInt(1, ticketID);
        ResultSet legsRs = legsStmt.executeQuery();

        while (legsRs.next()) {
            String airline = legsRs.getString("airline_id");
            int flightNo = legsRs.getInt("flight_number");
            String from = legsRs.getString("depart_airportID");
            String to = legsRs.getString("arrival_airportID");
            Date depDate = legsRs.getDate("departure_date");
            int seat = legsRs.getInt("seatnum");
            String tClass = legsRs.getString("class");
            double base = legsRs.getDouble("price");

            double adjusted = base;
            if ("Business".equalsIgnoreCase(tClass)) adjusted = base * 1.5;
            else if ("First".equalsIgnoreCase(tClass)) adjusted = base * 2.0;

            fareSum += adjusted;
%>
        <tr>
            <td><%= airline %></td>
            <td><%= flightNo %></td>
            <td><%= from %></td>
            <td><%= to %></td>
            <td><%= depDate %></td>
            <td><%= seat %></td>
            <td><%= tClass %></td>
            <td>$<%= String.format("%.2f", base) %></td>
            <td>$<%= String.format("%.2f", adjusted) %></td>
        </tr>
<%
        }
%>
        <tr>
            <td colspan="8" style="text-align:right;"><strong>Booking Fee:</strong></td>
            <td>$<%= String.format("%.2f", (double) bookingFee) %></td>
        </tr>
        <tr>
            <td colspan="8" style="text-align:right;"><strong>Grand Total:</strong></td>
            <td><strong>$<%= String.format("%.2f", totalFare) %></strong></td>
        </tr>
    </table>
<%
        } else {
            out.println("<p>Error loading ticket summary.</p>");
        }

        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Database error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
%>
    <a class="button" href="homeCustomer.jsp">Home</a>
</body>
</html>


