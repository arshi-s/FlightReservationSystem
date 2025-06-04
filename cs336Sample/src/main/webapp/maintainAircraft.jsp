<%@ page import="java.sql.*" %>
<%
    String message = request.getParameter("message");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Maintain Aircraft</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table, th, td { border: 1px solid #ccc; border-collapse: collapse; padding: 8px; }
        th { background-color: #f2f2f2; }
        .form-section { margin-top: 30px; }
    </style>
</head>
<body>
    <h2>Manage Aircrafts</h2>

    <% if (message != null) { %>
        <p style="color: green;"><%= message %></p>
    <% } %>

    <!-- Display all aircraft -->
    <table>
        <tr>
            <th>Aircraft ID</th>
            <th>Seat Capacity</th>
            <th>Airline ID</th>
        </tr>
        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM aircraft");
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("aircraft_id") %></td>
            <td><%= rs.getInt("seat_capacity") %></td>
            <td><%= rs.getString("airline_id") %></td>
        </tr>
        <%
                }
                conn.close();
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error loading aircraft: " + e.getMessage() + "</p>");
            }
        %>
    </table>

    <!-- Add Aircraft -->
    <div class="form-section">
        <h3>Add Aircraft</h3>
        <form action="maintainAircraft" method="post">
            <input type="hidden" name="action" value="add">
            Aircraft ID: <input type="number" name="aircraft_id" required>
            Seat Capacity: <input type="number" name="seat_capacity" required>
            Airline ID: <input type="text" name="airline_id" maxlength="2" required>
            <input type="submit" value="Add Aircraft">
        </form>
    </div>

    <!-- Edit Aircraft -->
    <div class="form-section">
        <h3>Edit Aircraft</h3>
        <form action="maintainAircraft" method="post">
            <input type="hidden" name="action" value="edit">
            Select Aircraft ID:
            <select name="aircraft_id" required>
                <%
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                        PreparedStatement stmt = conn.prepareStatement("SELECT aircraft_id FROM aircraft");
                        ResultSet rs = stmt.executeQuery();
                        while (rs.next()) {
                %>
                <option value="<%= rs.getInt("aircraft_id") %>"><%= rs.getInt("aircraft_id") %></option>
                <%
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<option>Error loading aircraft</option>");
                    }
                %>
            </select>
            New Seat Capacity: <input type="number" name="seat_capacity" required>
            <input type="submit" value="Update Aircraft">
        </form>
    </div>

    <!-- Delete Aircraft -->
    <div class="form-section">
        <h3>Delete Aircraft</h3>
        <form action="maintainAircraft" method="post">
            <input type="hidden" name="action" value="delete">
            Select Aircraft ID:
            <select name="aircraft_id" required>
                <%
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                        PreparedStatement stmt = conn.prepareStatement(
                          "SELECT a.aircraft_id FROM aircraft a LEFT JOIN flights f ON a.aircraft_id = f.aircraft_id WHERE f.aircraft_id IS NULL");
                        ResultSet rs = stmt.executeQuery();
                        boolean found = false;
                        while (rs.next()) {
                            found = true;
                %>
                <option value="<%= rs.getInt("aircraft_id") %>"><%= rs.getInt("aircraft_id") %></option>
                <%
                        }
                        if (!found) {
                            out.println("<option disabled>No deletable aircraft available</option>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<option>Error loading aircraft</option>");
                    }
                %>
            </select>
            <input type="submit" value="Delete Aircraft">
        </form>
    </div>

    <br><a href="homeCustomerRep.jsp">Back to Home</a>
</body>
</html>
