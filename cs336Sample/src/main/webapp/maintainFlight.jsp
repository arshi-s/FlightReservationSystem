<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
  String message = request.getParameter("message");
  Class.forName("com.mysql.jdbc.Driver");
  Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
  PreparedStatement aircraftStmt = conn.prepareStatement("SELECT aircraft_id FROM aircraft");
  ResultSet aircraftRs = aircraftStmt.executeQuery();
  PreparedStatement airlineStmt = conn.prepareStatement("SELECT airline_id FROM airline");
  ResultSet airlineRs = airlineStmt.executeQuery();
  PreparedStatement airportStmt1 = conn.prepareStatement("SELECT airport_id FROM airport");
  ResultSet airportRs1 = airportStmt1.executeQuery();
  PreparedStatement airportStmt2 = conn.prepareStatement("SELECT airport_id FROM airport");
  ResultSet airportRs2 = airportStmt2.executeQuery();
  PreparedStatement allFlightsStmt = conn.prepareStatement("SELECT * FROM flights");
  ResultSet flightsRs = allFlightsStmt.executeQuery();

  // Time formatter
  SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Flights</title>
  <style>
      body { font-family: Arial; padding: 20px; }
      table, th, td { border: 1px solid #ccc; border-collapse: collapse; padding: 8px; }
      th { background-color: #f2f2f2; }
      .form-section { margin-top: 30px; }
  </style>
</head>
<body>
<h2>Maintain Flights</h2>
<% if (message != null) { %>
  <p style="color: green;"><%= message %></p>
<% } %>

<!-- BEGIN: Select & Delete Flight Form -->
<form action="maintainFlight" method="post" onsubmit="return confirm('Are you sure you want to delete the selected flight?');">
<h3>Existing Flights</h3>
<table>
  <tr>
      <th>Select</th>
      <th>Flight #</th><th>Type</th><th>Aircraft ID</th><th>Airline ID</th>
      <th>Dep Time</th><th>Arr Time</th><th>From</th><th>To</th>
      <th>Stops</th><th>Price</th>
  </tr>
  <%
  while (flightsRs.next()) {
      int fNum = flightsRs.getInt("flight_number");
      String airline = flightsRs.getString("airline_id");

      PreparedStatement checkTicket = conn.prepareStatement(
          "SELECT COUNT(*) FROM flightticketflights WHERE flight_number=? AND airline_id=?");
      checkTicket.setInt(1, fNum);
      checkTicket.setString(2, airline);
      ResultSet rs1 = checkTicket.executeQuery();
      rs1.next();
      boolean inTicket = rs1.getInt(1) > 0;

      PreparedStatement checkWaitlist = conn.prepareStatement(
          "SELECT COUNT(*) FROM waitinglist WHERE flight_number=? AND airline_id=?");
      checkWaitlist.setInt(1, fNum);
      checkWaitlist.setString(2, airline);
      ResultSet rs2 = checkWaitlist.executeQuery();
      rs2.next();
      boolean inWaitlist = rs2.getInt(1) > 0;

      boolean canDelete = !inTicket && !inWaitlist;
  %>
      <tr>
          <td>
              <% if (canDelete) { %>
                  <input type="radio" name="selectedFlight" value="<%= fNum %>_<%= airline %>">
              <% } else { %>
                  <input type="radio" disabled title="In Operation">
              <% } %>
          </td>
          <td><%= fNum %></td>
          <td><%= flightsRs.getString("type") %></td>
          <td><%= flightsRs.getInt("aircraft_id") %></td>
          <td><%= airline %></td>
          <td><%= timeFormat.format(flightsRs.getTime("dept_time")) %></td>
          <td><%= timeFormat.format(flightsRs.getTime("arrival_time")) %></td>
          <td><%= flightsRs.getString("depart_airportID") %></td>
          <td><%= flightsRs.getString("arrival_airportID") %></td>
          <td><%= flightsRs.getInt("stops") %></td>
          <td>$<%= flightsRs.getBigDecimal("price") %></td>
      </tr>
  <%
      rs1.close();
      rs2.close();
      checkTicket.close();
      checkWaitlist.close();
  }
  %>
</table>
<br>
<input type="hidden" name="action" value="delete">
<input type="submit" value="Delete Selected Flight">
</form>
<!-- END: Delete Form -->

<!-- BEGIN: Add/Update Form -->
<div class="form-section">
  <h3>Add / Update Flight</h3>
  <form action="maintainFlight" method="post">
      Flight Number: <input type="number" name="flight_number" required><br><br>
      Type: <input type="text" name="type" required><br><br>
      Aircraft ID:
      <select name="aircraft_id" required>
          <% aircraftRs.beforeFirst(); while (aircraftRs.next()) { %>
              <option value="<%= aircraftRs.getInt("aircraft_id") %>"><%= aircraftRs.getInt("aircraft_id") %></option>
          <% } %>
      </select><br><br>
      Airline ID:
      <select name="airline_id" required>
          <% airlineRs.beforeFirst(); while (airlineRs.next()) { %>
              <option value="<%= airlineRs.getString("airline_id") %>"><%= airlineRs.getString("airline_id") %></option>
          <% } %>
      </select><br><br>
      Departure Time: <input type="time" name="dept_time" required><br><br>
      Arrival Time: <input type="time" name="arrival_time" required><br><br>
      Departure Airport:
      <select name="depart_airportID" required>
          <% while (airportRs1.next()) { %>
              <option value="<%= airportRs1.getString("airport_id") %>"><%= airportRs1.getString("airport_id") %></option>
          <% } %>
      </select><br><br>
      Arrival Airport:
      <select name="arrival_airportID" required>
          <% while (airportRs2.next()) { %>
              <option value="<%= airportRs2.getString("airport_id") %>"><%= airportRs2.getString("airport_id") %></option>
          <% } %>
      </select><br><br>
      Stops: <input type="number" name="stops" required><br><br>
      Price: <input type="number" name="price" step="0.01" required><br><br>
      Action:
      <select name="action" required>
          <option value="add">Add</option>
          <option value="update">Update</option>
      </select><br><br>
      <input type="submit" value="Submit">
  </form>
</div>
</body>
</html>
<%
  flightsRs.close();
  aircraftRs.close();
  airlineRs.close();
  airportRs1.close();
  airportRs2.close();
  conn.close();
%>
