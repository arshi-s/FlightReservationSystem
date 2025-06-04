<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%
    String custID = request.getParameter("cust_id");
    String checkFlight = request.getParameter("check_flight");
    String checkAirline = request.getParameter("check_airline");
    String checkDate = request.getParameter("check_date");

    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    PreparedStatement stmt = conn.prepareStatement(
        "SELECT * FROM WaitingList WHERE custID = ?"
    );
    stmt.setInt(1, Integer.parseInt(custID));
    ResultSet rs = stmt.executeQuery();

    Map<String, String> flightStatuses = new HashMap<>();

    if (checkFlight != null && checkAirline != null && checkDate != null) {
        // Check FlightAvailability and priority
        PreparedStatement availStmt = conn.prepareStatement(
            "SELECT seat_availability FROM FlightAvailability WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?"
        );
        availStmt.setInt(1, Integer.parseInt(checkFlight));
        availStmt.setString(2, checkAirline);
        availStmt.setDate(3, java.sql.Date.valueOf(checkDate));
        ResultSet ars = availStmt.executeQuery();

        int seatAvailable = 0;
        if (ars.next()) {
            seatAvailable = ars.getInt("seat_availability");
        }
        ars.close();
        availStmt.close();

        PreparedStatement priorityStmt = conn.prepareStatement(
            "SELECT priority_number FROM WaitingList WHERE flight_number = ? AND airline_id = ? AND departure_date = ? AND custID = ?"
        );
        priorityStmt.setInt(1, Integer.parseInt(checkFlight));
        priorityStmt.setString(2, checkAirline);
        priorityStmt.setDate(3, java.sql.Date.valueOf(checkDate));
        priorityStmt.setInt(4, Integer.parseInt(custID));
        ResultSet prs = priorityStmt.executeQuery();

        int priority = -1;
        if (prs.next()) {
            priority = prs.getInt("priority_number");
        }
        prs.close();
        priorityStmt.close();

        if (seatAvailable > 0 && priority == 1) {
            flightStatuses.put(checkFlight + "|" + checkAirline + "|" + checkDate, "Open Slot - Ready to Book");
        } else {
            flightStatuses.put(checkFlight + "|" + checkAirline + "|" + checkDate, "Still Waiting");
        }
    }
%>

<html>
<head>
    <title>My Waiting List Status</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        .btn { padding: 5px 10px; }
    </style>
</head>
<body>
<h2>Flights You're Waiting For</h2>

<table>
<tr>
    <th>Flight Number</th>
    <th>Airline</th>
    <th>Departure Date</th>
    <th>Priority</th>
    <th>Status</th>
    <th>Action</th>
</tr>

<%
    while (rs.next()) {
        int flightNum = rs.getInt("flight_number");
        String airlineID = rs.getString("airline_id");
        String depDate = rs.getDate("departure_date").toString();
        int priority = rs.getInt("priority_number");

        String key = flightNum + "|" + airlineID + "|" + depDate;
        String statusMsg = flightStatuses.containsKey(key) ? flightStatuses.get(key) : "";
%>
<tr>
    <td><%= flightNum %></td>
    <td><%= airlineID %></td>
    <td><%= depDate %></td>
    <td><%= priority %></td>
    <td><%= statusMsg %></td>
    <td>
        <form method="get" action="viewWaitingStatus.jsp">
            <input type="hidden" name="cust_id" value="<%= custID %>">
            <input type="hidden" name="check_flight" value="<%= flightNum %>">
            <input type="hidden" name="check_airline" value="<%= airlineID %>">
            <input type="hidden" name="check_date" value="<%= depDate %>">
            <input type="submit" value="View Status" class="btn">
        </form>
    </td>
</tr>
<%
    }
    rs.close();
    stmt.close();
    conn.close();
%>
</table>

<br>
<a href="homeCustomer.jsp?cust_id=<%= custID %>">Back to Home</a>
</body>
</html>
