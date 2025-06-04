<%@ page import="java.sql.*" %>
<%
   String custID = request.getParameter("custID");
   if (custID == null) custID = "1";

   String airportOptions = "";
   String airlineOptions = "<option value=\"\">Any</option>";

   Connection conn = null;
   PreparedStatement ps = null;
   ResultSet rs = null;

   try {
       Class.forName("com.mysql.jdbc.Driver");
       conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

       // Load airports
       ps = conn.prepareStatement("SELECT airport_id, airport_name FROM airport");
       rs = ps.executeQuery();
       while (rs.next()) {
           String id = rs.getString("airport_id");
           String name = rs.getString("airport_name");
           airportOptions += "<option value=\"" + id + "\">" + id + " - " + name + "</option>\n";
       }
       rs.close();
       ps.close();

       // Load airlines
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

<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Search Flights - Rep View</title>
   <script>
       function toggleTripType() {
           const tripType = document.getElementById("trip_type").value;
           const returnFields = document.getElementById("roundTripFields");
           document.getElementById("formAction").action = tripType === "round" ? "displayRoundTrip.jsp" : "displayFlight.jsp";
           returnFields.style.display = tripType === "round" ? "block" : "none";
       }
   </script>
</head>
<body>

<h2>Search Flights for Customer</h2>
<p><strong>Booking for Customer ID:</strong> <%= custID %></p>

<form id="formAction" action="displayFlight.jsp" method="get">
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

   <br><br>Departure Date:
   <input type="date" name="depart_date" required>

   <br><br><input type="checkbox" name="flexible" value="true"> Flexible Dates (+/- 3 days)

   <div id="roundTripFields" style="display:none;">
       <br><br>Return Date:
       <input type="date" name="return_date">
   </div>

   <br><br>Sort By:
   <select name="sort_by">
       <option value="">None</option>
       <option value="price">Price</option>
       <option value="dept_time">Departure Date</option>
       <option value="arrival_time">Arrival Date</option>
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
