<%@ page import="java.sql.*" %>
<%
    String custID = request.getParameter("cust_id");
    if (custID == null) custID = "1";
%>

<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
    // Create a date formatter
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    
    // Get the current date and format it as a string
    String currentDate = formatter.format(new Date());
%>

<p>Current Date: <%= currentDate %></p>

<!DOCTYPE html>
<html>
<head>
    <title>Select One or More Flights</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        input[type=submit] { margin-top: 15px; }
    </style>
</head>
<body>
<h2>Select One or More Flights</h2>
<form method="post" action="makeReservation">
    <input type="hidden" name="cust_id" value="<%= custID %>">
    <table>
        <tr>
            <th>Select</th>
            <th>Airline</th>
            <th>Flight #</th>
            <th>From</th>
            <th>To</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Departure Date</th>
            <th>Class</th>
        </tr>
<%
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

        String query = "SELECT F.airline_id, F.flight_number, F.depart_airportID, F.arrival_airportID, " +
                       "F.dept_time, F.arrival_time, FD.dayid AS departure_date " +
                       "FROM Flights F JOIN FlightDays FD ON F.airline_id = FD.airline_id AND F.flight_number = FD.flight_number " +
                       "ORDER BY F.airline_id, F.flight_number, FD.dayid";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(query);
        int index = 0;
        while (rs.next()) {
            String airlineId = rs.getString("airline_id");
            int flightNumber = rs.getInt("flight_number");
            String from = rs.getString("depart_airportID");
            String to = rs.getString("arrival_airportID");
            String deptTime = rs.getString("dept_time");
            String arrTime = rs.getString("arrival_time");
            String departureDate = currentDate;
%>
        <tr>
            <td><input type="checkbox" name="selectedFlights" value="<%= index %>"></td>
            <td><%= airlineId %></td>
            <td><%= flightNumber %></td>
            <td><%= from %></td>
            <td><%= to %></td>
            <td><%= deptTime %></td>
            <td><%= arrTime %></td>
            <td><%= departureDate %></td>
            <td>
                <select name="ticket_class_<%= index %>">
                    <option value="economy">Economy</option>
                    <option value="business">Business</option>
                    <option value="first">First</option>
                </select>
            </td>
        </tr>
        <input type="hidden" name="airline_id_<%= index %>" value="<%= airlineId %>">
        <input type="hidden" name="flight_number_<%= index %>" value="<%= flightNumber %>">
        <input type="hidden" name="departure_date_<%= index %>" value="<%= departureDate %>">
<%
            index++;
        }
        conn.close();
%>
        <input type="hidden" name="flightCount" value="<%= index %>">
<%
    } catch (Exception e) {
        out.println("<tr><td colspan='9'>Error loading flights: " + e.getMessage() + "</td></tr>");
    }
%>
    </table>
    <input type="submit" value="Make Reservation">
</form>
<br>
<a href="home.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px;">Home</a>
</body>
</html>
