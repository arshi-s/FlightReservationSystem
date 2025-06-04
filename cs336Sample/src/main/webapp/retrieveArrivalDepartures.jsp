<%@ page import="java.sql.*" %>
<%
    String selectedAirport = request.getParameter("airport_id");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Arrivals and Departures</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 40px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>View Flights at a Given Airport</h2>

    <form method="get" action="">
        <label for="airport_id">Select Airport:</label>
        <select name="airport_id" required>
            <option value="">-- Select --</option>
<%
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
        PreparedStatement stmt = conn.prepareStatement("SELECT airport_id, airport_name FROM airport");
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            String id = rs.getString("airport_id");
            String name = rs.getString("airport_name");
            boolean selected = id.equals(selectedAirport);
%>
            <option value="<%= id %>" <%= selected ? "selected" : "" %>><%= id %> - <%= name %></option>
<%
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<option>Error loading airports</option>");
    }
%>
        </select>
        <input type="submit" value="View Flights">
    </form>

<% if (selectedAirport != null && !selectedAirport.isEmpty()) { %>
    <h3>Departing Flights from <%= selectedAirport %></h3>
    <table>
        <tr>
            <th>Flight Number</th>
            <th>Airline</th>
            <th>Departure Time</th>
            <th>Arrival Airport</th>
        </tr>
<%
    try {
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT f.flight_number, f.airline_id, f.dept_time, f.arrival_airportID FROM flights f WHERE f.depart_airportID = ?"
        );
        stmt.setString(1, selectedAirport);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("flight_number") %></td>
            <td><%= rs.getString("airline_id") %></td>
            <td><%= rs.getTime("dept_time") %></td>
            <td><%= rs.getString("arrival_airportID") %></td>
        </tr>
<%
        }
        rs.close();
        stmt.close();

        out.println("</table><h3>Arriving Flights at " + selectedAirport + "</h3><table>");
%>
        <tr>
            <th>Flight Number</th>
            <th>Airline</th>
            <th>Departure Airport</th>
            <th>Arrival Time</th>
        </tr>
<%
        stmt = conn.prepareStatement(
            "SELECT f.flight_number, f.airline_id, f.depart_airportID, f.arrival_time FROM flights f WHERE f.arrival_airportID = ?"
        );
        stmt.setString(1, selectedAirport);
        rs = stmt.executeQuery();
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("flight_number") %></td>
            <td><%= rs.getString("airline_id") %></td>
            <td><%= rs.getString("depart_airportID") %></td>
            <td><%= rs.getTime("arrival_time") %></td>
        </tr>
<%
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error retrieving flights: " + e.getMessage() + "</p>");
    }
%>
    </table>
<% } %>

<br><a href="homeCustomerRep.jsp">Back to Home</a>
</body>
</html>

