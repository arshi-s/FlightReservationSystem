<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.DateTimeFormatter, java.util.Set, java.util.HashSet, java.util.Collections" %>
<%
    String custID = request.getParameter("cust_id");
    String depart_airportID = request.getParameter("depart_airportID");
    String arrival_airportID = request.getParameter("arrival_airportID");
    int departDay = Integer.parseInt(request.getParameter("depart_day"));
    String flexible = request.getParameter("flexible");

    String sortBy = request.getParameter("sort_by");
    String airlineId = request.getParameter("airline_id");
    String maxStops = request.getParameter("max_stops");
    String maxPrice = request.getParameter("max_price");
    String earliest = request.getParameter("earliest_departure");
    String latest = request.getParameter("latest_arrival");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    

    LocalDate today = LocalDate.now();
    LocalDate sixMonthsLater = today.plusMonths(6);
    List<LocalDate> validDates = new ArrayList<>();
    /*for (LocalDate d = today; !d.isAfter(sixMonthsLater); d = d.plusDays(1)) {
        if (d.getDayOfWeek().getValue() == departDay) {
            validDates.add(d);
        }
    }*/
    /* commenting the below and replacing with either flexible 3 days or 6 months
    for (LocalDate d = today; !d.isAfter(sixMonthsLater); d = d.plusDays(1)) {
    if (d.getDayOfWeek().getValue() == departDay) {
        validDates.add(d);
        if ("true".equals(flexible)) {
            for (int offset = -3; offset <= 3; offset++) {
                LocalDate flexDate = d.plusDays(offset);
                if (!flexDate.isBefore(today) && !flexDate.isAfter(sixMonthsLater) && flexDate.getDayOfWeek().getValue() == departDay) {
                    validDates.add(flexDate);
                }
            }
        }
    }
    */
    if ("true".equalsIgnoreCase(flexible)) {
        // Step 1: Find the next date that matches departDay
        LocalDate baseDate = today;
        while (baseDate.getDayOfWeek().getValue() != departDay) {
            baseDate = baseDate.plusDays(1);
        }

        // Step 2: Add baseDate ± 3 days
        for (int i = -3; i <= 3; i++) {
            LocalDate flexDate = baseDate.plusDays(i);
            if (!flexDate.isBefore(today)) {
                validDates.add(flexDate);
            }
        }
    } else {
        for (LocalDate d = today; !d.isAfter(sixMonthsLater); d = d.plusDays(1)) {
            if (d.getDayOfWeek().getValue() == departDay) {
                validDates.add(d);
            }
        }
    }

    Set<LocalDate> uniqueDates = new HashSet<>(validDates);
    validDates = new ArrayList<>(uniqueDates);
    Collections.sort(validDates);


    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

    StringBuilder query = new StringBuilder(
        "SELECT DISTINCT f.flight_number, f.airline_id, f.dept_time, f.arrival_time, f.price, " +
        "TIMESTAMPDIFF(MINUTE, f.dept_time, f.arrival_time) AS duration, " +
        "a.airline_name, f.stops " +
        "FROM flights f " +
        "JOIN flightdays fd ON f.flight_number = fd.flight_number AND f.airline_id = fd.airline_id " +
        "JOIN airline a ON f.airline_id = a.airline_id " +
        "WHERE f.depart_airportID = ? AND f.arrival_airportID = ? AND fd.dayid = ?"
    );

    if (airlineId != null && !airlineId.isEmpty()) query.append(" AND f.airline_id = ?");
    if (maxStops != null && !maxStops.isEmpty()) query.append(" AND f.stops <= ?");
    if (maxPrice != null && !maxPrice.isEmpty()) query.append(" AND f.price <= ?");
    if (earliest != null && !earliest.isEmpty()) query.append(" AND f.dept_time >= ?");
    if (latest != null && !latest.isEmpty()) query.append(" AND f.arrival_time <= ?");

    if (sortBy != null && !sortBy.isEmpty()) {
        if (sortBy.equals("duration")) {
            query.append(" ORDER BY duration");
        } else {
            query.append(" ORDER BY f.").append(sortBy);
        }
    }

    PreparedStatement pstmt = conn.prepareStatement(query.toString());

    int paramIndex = 1;
    pstmt.setString(paramIndex++, depart_airportID);
    pstmt.setString(paramIndex++, arrival_airportID);
    pstmt.setInt(paramIndex++, departDay);

    if (airlineId != null && !airlineId.isEmpty()) pstmt.setString(paramIndex++, airlineId);
    if (maxStops != null && !maxStops.isEmpty()) pstmt.setInt(paramIndex++, Integer.parseInt(maxStops));
    if (maxPrice != null && !maxPrice.isEmpty()) pstmt.setBigDecimal(paramIndex++, new java.math.BigDecimal(maxPrice));
    if (earliest != null && !earliest.isEmpty()) pstmt.setTime(paramIndex++, java.sql.Time.valueOf(earliest + ":00"));
    if (latest != null && !latest.isEmpty()) pstmt.setTime(paramIndex++, java.sql.Time.valueOf(latest + ":00"));

    ResultSet rs = pstmt.executeQuery();
%>
<h2>Matching One-Way Flights (for next 6 months if flexible is not chosen. If flexible chosen it's within 3 days of the day)</h2>
<table border="1">
<tr>
    <th>Flight</th><th>Airline</th><th>Departure</th><th>Arrival</th><th>Stops</th><th>Price</th><th>Date</th><th>Class</th><th></th>
</tr>
<%
    for (LocalDate depDate : validDates) {
        rs.beforeFirst();
        while (rs.next()) {
            String flightNumber = rs.getString("flight_number");
            String airlineIdVal = rs.getString("airline_id");

            PreparedStatement seatStmt = conn.prepareStatement(
                "SELECT seat_availability FROM FlightAvailability WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?"
            );
            seatStmt.setInt(1, Integer.parseInt(flightNumber));
            seatStmt.setString(2, airlineIdVal);
            seatStmt.setDate(3, java.sql.Date.valueOf(depDate));
            ResultSet seatRS = seatStmt.executeQuery();

            boolean exists = seatRS.next();
            int seatsLeft = exists ? seatRS.getInt("seat_availability") : -1;

            seatRS.close();
            seatStmt.close();
%>
<tr>
    <td><%= flightNumber %></td>
    <td><%= rs.getString("airline_name") %></td>
    <td><%= rs.getTime("dept_time") %></td>
    <td><%= rs.getTime("arrival_time") %></td>
    <td><%= rs.getInt("stops") %></td>
    <td>$<%= rs.getBigDecimal("price") %></td>
    <td><%= depDate.format(dtf) %></td>
    <td>
    <% if (!exists || seatsLeft > 0) { %>
        <form action="makeReservation" method="post">
            <input type="hidden" name="cust_id" value="<%= custID %>">
            <input type="hidden" name="flight_number_0" value="<%= flightNumber %>">
            <input type="hidden" name="airline_id_0" value="<%= airlineIdVal %>">
            <input type="hidden" name="departure_date_0" value="<%= depDate.format(dtf) %>">
            <select name="ticket_class_0">
                <option value="economy">Economy</option>
                <option value="business">Business</option>
                <option value="first">First</option>
            </select>
            <input type="submit" value="Select">
        </form>
    <% } else { %>
        <span style="color:red;">Full</span>
        <form action="JoinWaitingListServlet" method="post">
            <input type="hidden" name="cust_id" value="<%= custID %>">
            <input type="hidden" name="flight_number" value="<%= flightNumber %>">
            <input type="hidden" name="airline_id" value="<%= airlineIdVal %>">
            <input type="hidden" name="departure_date" value="<%= depDate.format(dtf) %>">
            <input type="submit" value="Join Waitlist">
        </form>
    <% } %>
    </td>
</tr>
<%
        }
    }
    rs.close();
    pstmt.close();
    conn.close();
%>
</table>
</body>
</html>
