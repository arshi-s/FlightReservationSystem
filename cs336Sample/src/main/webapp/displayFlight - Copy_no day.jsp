<%@ page import="java.sql.*, java.time.*, java.util.*" %>
<%
    String custID = request.getParameter("cust_id");
    String depart_airportID = request.getParameter("depart_airportID");
    String arrival_airportID = request.getParameter("arrival_airportID");
    String departDateStr = request.getParameter("depart_date");
    LocalDate departDate = LocalDate.parse(departDateStr);
    int dayOfWeek = departDate.getDayOfWeek().getValue();

    String sortBy = request.getParameter("sort_by");
    String airlineFilter = request.getParameter("airline_id");
    String maxStops = request.getParameter("max_stops");
    String maxPrice = request.getParameter("max_price");
    String earliest = request.getParameter("earliest_departure");
    String latest = request.getParameter("latest_arrival");

    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    StringBuilder query = new StringBuilder(
        "SELECT DISTINCT f.flight_number, f.airline_id, f.dept_time, f.arrival_time, f.price, " +
        "a.airline_name, f.stops FROM flights f " +
        "JOIN flightdays fd ON f.flight_number = fd.flight_number AND f.airline_id = fd.airline_id " +
        "JOIN airline a ON f.airline_id = a.airline_id " +
        "WHERE f.depart_airportID = ? AND f.arrival_airportID = ? AND fd.dayid = ?"
    );

    if (airlineFilter != null && !airlineFilter.isEmpty()) query.append(" AND f.airline_id = ?");
    if (maxStops != null && !maxStops.isEmpty()) query.append(" AND f.stops <= ?");
    if (maxPrice != null && !maxPrice.isEmpty()) query.append(" AND f.price <= ?");
    if (earliest != null && !earliest.isEmpty()) query.append(" AND f.dept_time >= ?");
    if (latest != null && !latest.isEmpty()) query.append(" AND f.arrival_time <= ?");
    if (sortBy != null && !sortBy.isEmpty()) query.append(" ORDER BY f." + sortBy);

    PreparedStatement stmt = conn.prepareStatement(query.toString());
    int i = 1;
    stmt.setString(i++, depart_airportID);
    stmt.setString(i++, arrival_airportID);
    stmt.setInt(i++, dayOfWeek);
    if (airlineFilter != null && !airlineFilter.isEmpty()) stmt.setString(i++, airlineFilter);
    if (maxStops != null && !maxStops.isEmpty()) stmt.setInt(i++, Integer.parseInt(maxStops));
    if (maxPrice != null && !maxPrice.isEmpty()) stmt.setDouble(i++, Double.parseDouble(maxPrice));
    if (earliest != null && !earliest.isEmpty()) stmt.setTime(i++, Time.valueOf(earliest + ":00"));
    if (latest != null && !latest.isEmpty()) stmt.setTime(i++, Time.valueOf(latest + ":00"));

    ResultSet rs = stmt.executeQuery();
%>

<html>
<head><title>Available Flights</title></head>
<body>
<h2>Available One-Way Flights</h2>
<form method="post" action="makeReservation">
    <input type="hidden" name="cust_id" value="<%= custID %>">
    <table border="1">
        <tr>
            <th>Select</th>
            <th>Flight Number</th>
            <th>Airline</th>
            <th>Departure Time</th>
            <th>Arrival Time</th>
            <th>Stops</th>
            <th>Price</th>
            <th>Class</th>
        </tr>
<%
    int index = 0;
    while (rs.next()) {
        String flightNum = rs.getString("flight_number");
        String airlineID = rs.getString("airline_id");
        String airlineName = rs.getString("airline_name");
        Time depTime = rs.getTime("dept_time");
        Time arrTime = rs.getTime("arrival_time");
        int stops = rs.getInt("stops");
        double price = rs.getDouble("price");
%>
        <tr>
            <td>
                <input type="radio" name="selectedRow" value="<%= index %>" required>
                <input type="hidden" name="airline_id_<%= index %>" value="<%= airlineID %>">
                <input type="hidden" name="flight_number_<%= index %>" value="<%= flightNum %>">
                <input type="hidden" name="departure_date_<%= index %>" value="<%= departDate %>">
            </td>
            <td><%= flightNum %></td>
            <td><%= airlineName %></td>
            <td><%= depTime %></td>
            <td><%= arrTime %></td>
            <td><%= stops %></td>
            <td>$<%= price %></td>
            <td>
                <select name="ticket_class_<%= index %>">
                    <option value="economy">Economy</option>
                    <option value="business">Business</option>
                    <option value="first">First</option>
                </select>
            </td>
        </tr>
<%      index++; }
    rs.close();
    stmt.close();
    conn.close();
%>
    </table>
    <input type="hidden" name="flightCount" value="<%= index %>">
    <br><input type="submit" value="Book Selected Flight">
</form>
</body>
</html>