<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeFormatter, java.util.*, java.math.BigDecimal, java.util.Set, java.util.HashSet, java.util.Collections" %>
<%
    String custID = request.getParameter("cust_id");
    String depart_airportID = request.getParameter("depart_airportID");
    String arrival_airportID = request.getParameter("arrival_airportID");
    int departDay = Integer.parseInt(request.getParameter("depart_day"));
    int returnDay = Integer.parseInt(request.getParameter("return_day"));
    String flexible = request.getParameter("flexible");

    String sortBy = request.getParameter("sort_by");
    String airlineFilter = request.getParameter("airline_id");
    String maxStops = request.getParameter("max_stops");
    String maxPrice = request.getParameter("max_price");
    String earliest = request.getParameter("earliest_departure");
    String latest = request.getParameter("latest_arrival");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    LocalDate today = LocalDate.now();
    LocalDate sixMonthsLater = today.plusMonths(6);

    List<LocalDate> depDates = new ArrayList<>();
    List<LocalDate> retDates = new ArrayList<>();

    /*for (LocalDate date = today; !date.isAfter(sixMonthsLater); date = date.plusDays(1)) {
        if (date.getDayOfWeek().getValue() == departDay) depDates.add(date);
        if (date.getDayOfWeek().getValue() == returnDay) retDates.add(date);
    }*/
    /*
    for (LocalDate date = today; !date.isAfter(sixMonthsLater); date = date.plusDays(1)) {
    if (date.getDayOfWeek().getValue() == departDay) {
        depDates.add(date);
        if ("true".equals(flexible)) {
            for (int i = -3; i <= 3; i++) {
                LocalDate flex = date.plusDays(i);
                if (!flex.isBefore(today) && !flex.isAfter(sixMonthsLater) && flex.getDayOfWeek().getValue() == departDay) {
                    depDates.add(flex);
                }
            }
        }
    }
    if (date.getDayOfWeek().getValue() == returnDay) {
        retDates.add(date);
        if ("true".equals(flexible)) {
            for (int i = -3; i <= 3; i++) {
                LocalDate flex = date.plusDays(i);
                if (!flex.isBefore(today) && !flex.isAfter(sixMonthsLater) && flex.getDayOfWeek().getValue() == returnDay) {
                    retDates.add(flex);
                }
            }
        }
    }
}
*/
if ("true".equalsIgnoreCase(flexible)) {
    // For departDay
    LocalDate nextDep = today;
    while (nextDep.getDayOfWeek().getValue() != departDay) {
        nextDep = nextDep.plusDays(1);
    }
    for (int i = -3; i <= 3; i++) {
        LocalDate d = nextDep.plusDays(i);
        if (!d.isBefore(today)) {
            depDates.add(d);
        }
    }

    // For returnDay
    LocalDate nextRet = today;
    while (nextRet.getDayOfWeek().getValue() != returnDay) {
        nextRet = nextRet.plusDays(1);
    }
    for (int i = -3; i <= 3; i++) {
        LocalDate d = nextRet.plusDays(i);
        if (!d.isBefore(today)) {
            retDates.add(d);
        }
    }
} else {
    for (LocalDate d = today; !d.isAfter(sixMonthsLater); d = d.plusDays(1)) {
        if (d.getDayOfWeek().getValue() == departDay) depDates.add(d);
        if (d.getDayOfWeek().getValue() == returnDay) retDates.add(d);
    }
}

// Deduplicate and sort
    Set<LocalDate> uniqueDep = new HashSet<>(depDates);
    depDates = new ArrayList<>(uniqueDep);
    Collections.sort(depDates);

    Set<LocalDate> uniqueRet = new HashSet<>(retDates);
    retDates = new ArrayList<>(uniqueRet);
    Collections.sort(retDates);


    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    StringBuilder baseQuery = new StringBuilder(
        "SELECT DISTINCT f.flight_number, f.airline_id, f.dept_time, f.arrival_time, f.price, " +
        		"TIMESTAMPDIFF(MINUTE, f.dept_time, f.arrival_time) AS duration, " +
        "a.airline_name, f.stops FROM flights f " +
        "JOIN flightdays fd ON f.flight_number = fd.flight_number AND f.airline_id = fd.airline_id " +
        "JOIN airline a ON f.airline_id = a.airline_id " +
        "WHERE f.depart_airportID = ? AND f.arrival_airportID = ? AND fd.dayid = ?"
    );
    if (airlineFilter != null && !airlineFilter.isEmpty()) baseQuery.append(" AND f.airline_id = '").append(airlineFilter).append("'");
    if (maxStops != null && !maxStops.isEmpty()) baseQuery.append(" AND f.stops <= ").append(maxStops);
    if (maxPrice != null && !maxPrice.isEmpty()) baseQuery.append(" AND f.price <= ").append(maxPrice);
    if (earliest != null && !earliest.isEmpty()) baseQuery.append(" AND f.dept_time >= '").append(earliest).append(":00'");
    if (latest != null && !latest.isEmpty()) baseQuery.append(" AND f.arrival_time <= '").append(latest).append(":00'");
    // if (sortBy != null && !sortBy.isEmpty()) baseQuery.append(" ORDER BY f.").append(sortBy);
    if (sortBy != null && !sortBy.isEmpty()) {
        if (sortBy.equals("duration")) {
            baseQuery.append(" ORDER BY duration");
        } else {
            baseQuery.append(" ORDER BY f.").append(sortBy);
        }
    }

    List<Map<String, Object>> depFlights = new ArrayList<>();
    List<Map<String, Object>> retFlights = new ArrayList<>();

    for (LocalDate d : depDates) {
        PreparedStatement stmt = conn.prepareStatement(baseQuery.toString());
        stmt.setString(1, depart_airportID);
        stmt.setString(2, arrival_airportID);
        stmt.setInt(3, departDay);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("flight_number", rs.getString("flight_number"));
            row.put("airline_id", rs.getString("airline_id"));
            row.put("airline_name", rs.getString("airline_name"));
            row.put("dept_time", rs.getTime("dept_time"));
            row.put("arrival_time", rs.getTime("arrival_time"));
            row.put("price", rs.getBigDecimal("price"));
            row.put("stops", rs.getInt("stops"));
            row.put("date", d);
            depFlights.add(row);
        }
        rs.close();
        stmt.close();
    }

    for (LocalDate d : retDates) {
        PreparedStatement stmt = conn.prepareStatement(baseQuery.toString());
        stmt.setString(1, arrival_airportID);
        stmt.setString(2, depart_airportID);
        stmt.setInt(3, returnDay);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("flight_number", rs.getString("flight_number"));
            row.put("airline_id", rs.getString("airline_id"));
            row.put("airline_name", rs.getString("airline_name"));
            row.put("dept_time", rs.getTime("dept_time"));
            row.put("arrival_time", rs.getTime("arrival_time"));
            row.put("price", rs.getBigDecimal("price"));
            row.put("stops", rs.getInt("stops"));
            row.put("date", d);
            retFlights.add(row);
        }
        rs.close();
        stmt.close();
    }
%>
<html>
<head><title>Available Round Trip Flights</title></head>
<body>
<h2>Select Round Trip Flight Combination (for next 6 months if flexible is not chosen. If flexible chosen it's within 3 days of the day)</h2>
<form method="post" action="makeReservation">
<input type="hidden" name="cust_id" value="<%= custID %>">
<br><input type="submit" value="Book Selected Round Trip">
<table border="1">
<tr>
    <th>Select</th><th>Dep Flight</th><th>Airline</th><th>Dep Time</th><th>Arr Time</th><th>Stops</th><th>Price</th><th>Date</th>
    <th>Return Flight</th><th>Airline</th><th>Dep Time</th><th>Arr Time</th><th>Stops</th><th>Price</th><th>Date</th><th>Total</th><th>Class</th>
</tr>
<%
    int row = 0;
    for (Map<String, Object> dep : depFlights) {
        for (Map<String, Object> ret : retFlights) {
            LocalDate depDate = (LocalDate) dep.get("date");
            LocalDate retDate = (LocalDate) ret.get("date");
            if (retDate.isBefore(depDate)) continue;
            if (retDate.equals(depDate) && ((Time) ret.get("dept_time")).before((Time) dep.get("arrival_time"))) continue;

            BigDecimal depPrice = (BigDecimal) dep.get("price");
            BigDecimal retPrice = (BigDecimal) ret.get("price");
            BigDecimal total = depPrice.add(retPrice);
            String depFlight = (String) dep.get("flight_number");
            String depAirline = (String) dep.get("airline_id");
            String retFlight = (String) ret.get("flight_number");
            String retAirline = (String) ret.get("airline_id");
%>
<tr>
    <td>
        <input type="radio" name="selectedRow" value="<%= row %>" required>
        <input type="hidden" name="flightinfo_<%= row %>" value="<%= depFlight %>|<%= depAirline %>|<%= depDate %>|<%= retFlight %>|<%= retAirline %>|<%= retDate %>">
    </td>
    <td><%= depFlight %></td><td><%= dep.get("airline_name") %></td><td><%= dep.get("dept_time") %></td><td><%= dep.get("arrival_time") %></td>
    <td><%= dep.get("stops") %></td><td>$<%= depPrice %></td><td><%= depDate %></td>
    <td><%= retFlight %></td><td><%= ret.get("airline_name") %></td><td><%= ret.get("dept_time") %></td><td><%= ret.get("arrival_time") %></td>
    <td><%= ret.get("stops") %></td><td>$<%= retPrice %></td><td><%= retDate %></td><td>$<%= total %></td>
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
</form>
</body>
</html>
