<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeFormatter, java.util.*, java.math.BigDecimal" %>

<%
    String custID = request.getParameter("cust_id");
    String depart_airportID = request.getParameter("depart_airportID");
    String arrival_airportID = request.getParameter("arrival_airportID");
    String departDateStr = request.getParameter("depart_date");
    String returnDateStr = request.getParameter("return_date");
    String flexible = request.getParameter("flexible");

    String sortBy = request.getParameter("sort_by");
    String airlineFilter = request.getParameter("airline_id");
    String maxStops = request.getParameter("max_stops");
    String maxPrice = request.getParameter("max_price");
    String earliest = request.getParameter("earliest_departure");
    String latest = request.getParameter("latest_arrival");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    LocalDate departDate = LocalDate.parse(departDateStr);
    LocalDate returnDate = LocalDate.parse(returnDateStr);

    List<LocalDate> depDates = new ArrayList<>();
    List<Integer> depDays = new ArrayList<>();
    List<LocalDate> retDates = new ArrayList<>();
    List<Integer> retDays = new ArrayList<>();

    if ("true".equals(flexible)) {
        for (int i = -3; i <= 3; i++) {
            depDates.add(departDate.plusDays(i));
            depDays.add(departDate.plusDays(i).getDayOfWeek().getValue());
            retDates.add(returnDate.plusDays(i));
            retDays.add(returnDate.plusDays(i).getDayOfWeek().getValue());
        }
    } else {
        depDates.add(departDate);
        depDays.add(departDate.getDayOfWeek().getValue());
        retDates.add(returnDate);
        retDays.add(returnDate.getDayOfWeek().getValue());
    }

    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    String baseQuery = "SELECT DISTINCT f.flight_number, f.airline_id, f.dept_time, f.arrival_time, f.price, " +
                       "a.airline_name, f.stops " +
                       "FROM flights f " +
                       "JOIN flightdays fd ON f.flight_number = fd.flight_number AND f.airline_id = fd.airline_id " +
                       "JOIN airline a ON f.airline_id = a.airline_id " +
                       "WHERE f.depart_airportID = ? AND f.arrival_airportID = ? AND fd.dayid IN (";

    StringBuilder filters = new StringBuilder();
    if (airlineFilter != null && !airlineFilter.isEmpty()) filters.append(" AND f.airline_id = '").append(airlineFilter).append("'");
    if (maxStops != null && !maxStops.isEmpty()) filters.append(" AND f.stops <= ").append(maxStops);
    if (maxPrice != null && !maxPrice.isEmpty()) filters.append(" AND f.price <= ").append(maxPrice);
    if (earliest != null && !earliest.isEmpty()) filters.append(" AND f.dept_time >= '").append(earliest).append(":00'");
    if (latest != null && !latest.isEmpty()) filters.append(" AND f.arrival_time <= '").append(latest).append(":00'");
    if (sortBy != null && !sortBy.isEmpty()) filters.append(" ORDER BY f.").append(sortBy);

    List<Map<String, Object>> depFlights = new ArrayList<>();
    List<Map<String, Object>> retFlights = new ArrayList<>();

    for (LocalDate date : depDates) {
        StringBuilder depQuery = new StringBuilder(baseQuery);
        for (int i = 0; i < depDays.size(); i++) {
            depQuery.append("?");
            if (i < depDays.size() - 1) depQuery.append(", ");
        }
        depQuery.append(")").append(filters);
        PreparedStatement depStmt = conn.prepareStatement(depQuery.toString());
        depStmt.setString(1, depart_airportID);
        depStmt.setString(2, arrival_airportID);
        for (int i = 0; i < depDays.size(); i++) {
            depStmt.setInt(i + 3, depDays.get(i));
        }
        ResultSet rs = depStmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("flight_number", rs.getString("flight_number"));
            row.put("airline_id", rs.getString("airline_id"));
            row.put("airline_name", rs.getString("airline_name"));
            row.put("dept_time", rs.getTime("dept_time"));
            row.put("arrival_time", rs.getTime("arrival_time"));
            row.put("price", rs.getBigDecimal("price"));
            row.put("stops", rs.getInt("stops"));
            row.put("date", date);
            depFlights.add(row);
        }
        rs.close();
        depStmt.close();
    }

    for (LocalDate date : retDates) {
        StringBuilder retQuery = new StringBuilder(baseQuery);
        for (int i = 0; i < retDays.size(); i++) {
            retQuery.append("?");
            if (i < retDays.size() - 1) retQuery.append(", ");
        }
        retQuery.append(")").append(filters);
        PreparedStatement retStmt = conn.prepareStatement(retQuery.toString());
        retStmt.setString(1, arrival_airportID);
        retStmt.setString(2, depart_airportID);
        for (int i = 0; i < retDays.size(); i++) {
            retStmt.setInt(i + 3, retDays.get(i));
        }
        ResultSet rs = retStmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("flight_number", rs.getString("flight_number"));
            row.put("airline_id", rs.getString("airline_id"));
            row.put("airline_name", rs.getString("airline_name"));
            row.put("dept_time", rs.getTime("dept_time"));
            row.put("arrival_time", rs.getTime("arrival_time"));
            row.put("price", rs.getBigDecimal("price"));
            row.put("stops", rs.getInt("stops"));
            row.put("date", date);
            retFlights.add(row);
        }
        rs.close();
        retStmt.close();
    }
%>
<html>
<head><title>Available Round Trip Flights</title></head>
<body>
<h2>Select Round Trip Flight Combination</h2>
<form method="post" action="makeReservation">
<input type="hidden" name="cust_id" value="<%= custID %>">
<table border="1">
<tr>
    <th>Select</th><th>Dep Flight</th><th>Airline</th><th>Dep Time</th><th>Arr Time</th><th>Stops</th><th>Price</th><th>Date</th>
    <th>Return Flight</th><th>Airline</th><th>Dep Time</th><th>Arr Time</th><th>Stops</th><th>Price</th><th>Date</th><th>Total Price</th><th>Class</th>
</tr>
<%
    int row = 0;
    for (Map<String, Object> dep : depFlights) {
        for (Map<String, Object> ret : retFlights) {
            BigDecimal depPrice = (BigDecimal) dep.get("price");
            BigDecimal retPrice = (BigDecimal) ret.get("price");
            BigDecimal total = depPrice.add(retPrice);
            String depFlight = (String) dep.get("flight_number");
            String depAirline = (String) dep.get("airline_id");
            String depDate = ((LocalDate) dep.get("date")).toString();
            String retFlight = (String) ret.get("flight_number");
            String retAirline = (String) ret.get("airline_id");
            String retDate = ((LocalDate) ret.get("date")).toString();
%>
<tr>
    <td>
        <input type="radio" name="selectedRow" value="<%= row %>">
        <input type="hidden" name="flightinfo_<%= row %>" value="<%= depFlight %>|<%= depAirline %>|<%= depDate %>|<%= retFlight %>|<%= retAirline %>|<%= retDate %>">
    </td>
    <td><%= depFlight %></td>
    <td><%= dep.get("airline_name") %></td>
    <td><%= dep.get("dept_time") %></td>
    <td><%= dep.get("arrival_time") %></td>
    <td><%= dep.get("stops") %></td>
    <td>$<%= depPrice %></td>
    <td><%= depDate %></td>
    <td><%= retFlight %></td>
    <td><%= ret.get("airline_name") %></td>
    <td><%= ret.get("dept_time") %></td>
    <td><%= ret.get("arrival_time") %></td>
    <td><%= ret.get("stops") %></td>
    <td>$<%= retPrice %></td>
    <td><%= retDate %></td>
    <td>$<%= total %></td>
    <td>
        <select name="class_<%= row %>">
            <option value="economy">Economy</option>
            <option value="business">Business</option>
            <option value="first">First</option>
        </select>
    </td>
</tr>
<% row++; }} %>
</table>
<br><input type="submit" value="Book Selected Round Trip">
</form>
</body>
</html>