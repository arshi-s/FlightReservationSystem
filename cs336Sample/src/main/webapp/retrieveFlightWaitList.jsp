<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Retrieve Waitlisted Passengers</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 90%; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        select, input[type=submit] { margin-top: 10px; }
    </style>
</head>
<body>

<h2>View Waiting List for a Flight</h2>

<form method="get" action="">
    <label>Select Flight:</label><br>
    Airline ID:
    <select name="airline_id" required>
        <option value="">-- Select Airline --</option>
        <%
            try (
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                PreparedStatement stmt = conn.prepareStatement("SELECT DISTINCT airline_id FROM flights ORDER BY airline_id");
                ResultSet rs = stmt.executeQuery();
            ) {
                while (rs.next()) {
                    String airline = rs.getString("airline_id");
        %>
        <option value="<%= airline %>"><%= airline %></option>
        <%
                }
            } catch (Exception e) {
                out.println("<option>Error loading airlines</option>");
            }
        %>
    </select>

    <br><br>Flight Number:
    <select name="flight_number" required>
        <option value="">-- Select Flight Number --</option>
        <%
            try (
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                PreparedStatement stmt = conn.prepareStatement("SELECT DISTINCT flight_number FROM flights ORDER BY flight_number");
                ResultSet rs = stmt.executeQuery();
            ) {
                while (rs.next()) {
                    int num = rs.getInt("flight_number");
        %>
        <option value="<%= num %>"><%= num %></option>
        <%
                }
            } catch (Exception e) {
                out.println("<option>Error loading flights</option>");
            }
        %>
    </select>

    <br><br>Departure Date: 
    <input type="date" name="departure_date" required>

    <br><br><input type="submit" value="View Waiting List">
</form>

<%
    String airlineId = request.getParameter("airline_id");
    String flightNumber = request.getParameter("flight_number");
    String departureDate = request.getParameter("departure_date");

    if (airlineId != null && flightNumber != null && departureDate != null) {
        try (
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT w.custID, c.fname, c.lname, w.priority_number " +
                "FROM waitinglist w " +
                "JOIN customer c ON w.custID = c.custID " +
                "WHERE w.airline_id = ? AND w.flight_number = ? AND w.departure_date = ? " +
                "ORDER BY w.priority_number"
            );
        ) {
            stmt.setString(1, airlineId);
            stmt.setInt(2, Integer.parseInt(flightNumber));
            stmt.setDate(3, Date.valueOf(departureDate));

            ResultSet rs = stmt.executeQuery();

            boolean found = false;
%>

<h3>Waitlisted Passengers:</h3>
<table>
    <tr>
        <th>Customer ID</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Priority Number</th>
    </tr>
<%
            while (rs.next()) {
                found = true;
%>
    <tr>
        <td><%= rs.getInt("custID") %></td>
        <td><%= rs.getString("fname") %></td>
        <td><%= rs.getString("lname") %></td>
        <td><%= rs.getInt("priority_number") %></td>
    </tr>
<%
            }

            if (!found) {
%>
    <tr><td colspan="4">No passengers are currently on the waiting list for this flight.</td></tr>
<%
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error retrieving waiting list: " + e.getMessage() + "</p>");
        }
    }
%>

</table>
<br><a href="homeCustomerRep.jsp">Back to Home</a>
</body>
</html>


