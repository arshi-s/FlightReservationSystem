<%@ page import="java.sql.*" %>
<%
   String custID = request.getParameter("cust_id");
   if (custID == null) custID = "1";

   String airportOptions = "";
   String airlineOptions = "<option value=\"\">Any</option>";

   Connection conn = null;
   PreparedStatement ps = null;
   ResultSet rs = null;

   try {
       Class.forName("com.mysql.jdbc.Driver");
       conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

       ps = conn.prepareStatement("SELECT airport_id, airport_name FROM airport");
       rs = ps.executeQuery();
       while (rs.next()) {
           String id = rs.getString("airport_id");
           String name = rs.getString("airport_name");
           airportOptions += "<option value=\"" + id + "\">" + id + " - " + name + "</option>\n";
       }
       rs.close();
       ps.close();

       ps = conn.prepareStatement("SELECT airline_id, airline_name FROM airline");
       rs = ps.executeQuery();
       while (rs.next()) {
           String id = rs.getString("airline_id");
           String name = rs.getString("airline_name");
           airlineOptions += "<option value=\"" + id + "\">" + id + " - " + name + "</option>\n";
       }
   } catch (Exception e) {
       airportOptions = "<option>Error loading airports</option>";
       airlineOptions += "<option>Error loading airlines</option>";
   } finally {
       if (rs != null) rs.close();
       if (ps != null) ps.close();
       if (conn != null) conn.close();
   }
%>

<html>
<head>
   <title>Search Flights</title>
   <script>
       function toggleTripType() {
           const tripType = document.getElementById("trip_type").value;
           const returnDay = document.getElementById("return_day");
           const form = document.getElementById("flightForm");

           if (tripType === "round") {
               returnDay.disabled = false;
               returnDay.required = true;
               form.action = "displayRoundTrip.jsp";
           } else {
               returnDay.disabled = true;
               returnDay.required = false;
               form.action = "displayFlight.jsp";
           }
       }

       window.onload = toggleTripType;
   </script>
</head>
<body>
<h2>Search Flights</h2>
<p>Your Customer ID: <%= custID %></p>

<form id="flightForm" method="get" action="displayFlight.jsp">
   <input type="hidden" name="cust_id" value="<%= custID %>">

   Trip Type:
   <select id="trip_type" name="trip_type" onchange="toggleTripType()">
       <option value="oneway">One-Way</option>
       <option value="round">Round-Trip</option>
   </select>

   <br><br>Departure Airport:
   <select name="depart_airportID">
       <%= airportOptions %>
   </select>

   <br><br>Arrival Airport:
   <select name="arrival_airportID">
       <%= airportOptions %>
   </select>

   <br><br>Departure Day:
   <select name="depart_day" required>
       <option value="1">Monday</option>
       <option value="2">Tuesday</option>
       <option value="3">Wednesday</option>
       <option value="4">Thursday</option>
       <option value="5">Friday</option>
       <option value="6">Saturday</option>
       <option value="7">Sunday</option>
   </select>

   <br><br>Return Day (required for round-trip):
   <select name="return_day" id="return_day">
       <option value="">-- None --</option>
       <option value="1">Monday</option>
       <option value="2">Tuesday</option>
       <option value="3">Wednesday</option>
       <option value="4">Thursday</option>
       <option value="5">Friday</option>
       <option value="6">Saturday</option>
       <option value="7">Sunday</option>
   </select>

   <br><br><input type="checkbox" name="flexible" value="true"> Flexible Dates (+/- 3 days)

   <br><br>Sort By:
   <select name="sort_by">
       <option value="">None</option>
       <option value="price">Price</option>
       <option value="dept_time">Departure Time</option>
       <option value="arrival_time">Arrival Time</option>
       <option value="duration">Duration</option>
   </select>

   <br><br>Filter By Airline:
   <select name="airline_id">
       <%= airlineOptions %>
   </select>

   <br><br>Max Price:
   <input type="number" name="max_price" step="0.01">

   <br><br>Max Stops:
   <select name="max_stops">
       <option value="">Any</option>
       <option value="0">Non-stop</option>
       <option value="1">1 stop or fewer</option>
       <option value="2">2 stops or fewer</option>
   </select>

   <br><br>Earliest Take-Off Time:
   <input type="time" name="earliest_departure">

   <br><br>Latest Landing Time:
   <input type="time" name="latest_arrival">

   <br><br><input type="submit" value="Search Flights">
</form>
</body>
</html>
