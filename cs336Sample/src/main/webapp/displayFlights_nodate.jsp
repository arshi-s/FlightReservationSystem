<%@ page import="java.sql.*" %>

<%
    String custID = request.getParameter("cust_id");
    if (custID == null) custID = "1";
%>

<html>
<head><title>Available Flights</title></head>
<body>
<p>Your Customer ID: <%= custID %></p>
<%
    String depart_airportID = request.getParameter("depart_airportID");
    String arrival_airportID = request.getParameter("arrival_airportID");
    String dayId = request.getParameter("depart_day");
    String flexible = request.getParameter("flexible");
    String sortBy = request.getParameter("sort_by");
    String airlineId = request.getParameter("airline_id");
    String maxPrice = request.getParameter("max_price");
    String earliestDep = request.getParameter("earliest_departure");
    String latestArr = request.getParameter("latest_arrival");
    String maxStops = request.getParameter("max_stops");


    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
        
        StringBuilder query = new StringBuilder(
        		"SELECT f.flight_number, f.airline_id, f.dept_time, f.arrival_time, f.price, a.airline_name, f.stops, " +
        	    "TIMESTAMPDIFF(MINUTE, f.dept_time, f.arrival_time) AS duration " +
        	    "FROM flights f " +
        	    "JOIN flightdays o ON f.flight_number = o.flight_number " +
        	    "JOIN airline a ON f.airline_id = a.airline_id " +
        	    "WHERE f.depart_airportID = ? AND f.arrival_airportID = ?"
        	);


        // Only add day_id if present
        boolean hasDay = (dayId != null && !dayId.isEmpty());
        if (hasDay) {
            if ("true".equals(flexible)) {
                query.append(" AND (((o.dayid - ?) + 7) % 7 <= 3 OR ((? - o.dayid + 7) % 7 <= 3))");
            } else {
                query.append(" AND o.dayid = ?");
            }
        }

        if (airlineId != null && !airlineId.isEmpty()) {
            query.append(" AND f.airline_id = ?");
        }
        if (maxStops != null && !maxStops.isEmpty()) {
            query.append(" AND f.stops <= ?");
        }

        if (maxPrice != null && !maxPrice.isEmpty()) {
            query.append(" AND f.price <= ?");
        }
        if (earliestDep != null && !earliestDep.isEmpty()) {
            query.append(" AND f.dept_time >= ?");
        }
        if (latestArr != null && !latestArr.isEmpty()) {
            query.append(" AND f.arrival_time <= ?");
        }

        if (sortBy != null && !sortBy.isEmpty()) {
            if (sortBy.equals("duration")) {
                query.append(" ORDER BY duration");
            } else {
                query.append(" ORDER BY f.").append(sortBy);
            }
        }

        pstmt = conn.prepareStatement(query.toString());

        int index = 1;
        pstmt.setString(index++, depart_airportID);
        pstmt.setString(index++, arrival_airportID);
        if (hasDay) {
            int d = Integer.parseInt(dayId);
            if ("true".equals(flexible)) {
                pstmt.setInt(index++, d);  // First ?
                pstmt.setInt(index++, d);  // Second ?
            } else {
                pstmt.setInt(index++, d);
            }
        }
        if (airlineId != null && !airlineId.isEmpty()) {
            pstmt.setString(index++, airlineId);
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            pstmt.setBigDecimal(index++, new java.math.BigDecimal(maxPrice));
        }
        if (maxStops != null && !maxStops.isEmpty()) {
            pstmt.setInt(index++, Integer.parseInt(maxStops));
        }
        
        if (earliestDep != null && earliestDep.trim().length() > 0) {
            try {
                if (!earliestDep.matches("\\d{2}:\\d{2}:\\d{2}")) {
                    earliestDep += ":00";
                }
                pstmt.setTime(index++, java.sql.Time.valueOf(earliestDep));
            } catch (IllegalArgumentException e) {
                out.println("Invalid earliest time format.");
                return;
            }
        }

        if (latestArr != null && latestArr.trim().length() > 0) {
            try {
                if (!latestArr.matches("\\d{2}:\\d{2}:\\d{2}")) {
                    latestArr += ":00";
                }
                pstmt.setTime(index++, java.sql.Time.valueOf(latestArr));
            } catch (IllegalArgumentException e) {
                out.println("Invalid latest time format.");
                return;
            }
        }


        rs = pstmt.executeQuery();
%>
<h2>Matching One-Way Flights</h2>
<table border="1">
<tr>
    <th>Flight ID</th>
    <th>Airline</th>
    <th>Departure Time</th>
    <th>Arrival Time</th>
    <th>Stops</th>
    <th>Price</th>
    <th></th>
</tr>

<%
    while (rs.next()) {
%>
<form action="makeReservation" method="post">
    <input type="hidden" name="selectedFlights" value="0">
    <input type="hidden" name="cust_id" value="<%= custID %>">
    <input type="hidden" name="flightCount" value="1">
    <input type="hidden" name="airline_id_0" value="<%= rs.getString("f.airline_id") %>">
    <input type="hidden" name="flight_number_0" value="<%= rs.getString("f.flight_number") %>">
    <input type="hidden" name="departure_date_0" value="2025-05-12">
    <input type="hidden" name="ticket_class_0" value="Economy">

    <!-- ✅ Add this line to support editing -->
    <input type="hidden" name="original_ticket_id" value="<%= request.getParameter("original_ticket_id") %>">

    <tr>
        <td><%= rs.getInt("flight_number") %></td>
        <td><%= rs.getString("airline_name") %></td>
        <td><%= new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("dept_time")) %></td>
        <td><%= new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("arrival_time")) %></td>
        <td><%= rs.getInt("stops") %></td>
        <td><%= rs.getBigDecimal("price") %></td>
        <td><input type="submit" value="Select"></td>
    </tr>
</form>


<%
    }
%>
</table>
<%
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
</body>
</html>
