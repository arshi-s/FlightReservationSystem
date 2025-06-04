<%@ page import="java.sql.*" %>
<%
String departureDate = (String) request.getAttribute("departure_date");
String custID = String.valueOf(request.getAttribute("cust_id"));
String error = (String) request.getAttribute("error");
String airlineId = (String) request.getAttribute("airline_id");
String flightNumber = String.valueOf(request.getAttribute("flight_number"));
%>

<!DOCTYPE html>
<html>
<head>
    <title>Reservation or Waiting List Already Exists for the Date and Flight</title>
</head>
<body>
    <h2>Click Home to Go Back </h2>
    <p>Departure Date: <%= departureDate %></p>
    
    <% System.out.println("error is " + error); %>
    <% System.out.println("airlineId is " + airlineId); %>
    <% System.out.println("flightNumber is " + flightNumber); %>

<% if (error != null) { %>
    <p style="color:red;"><%= ("duplicate".equals(error)) ? "You are already booked on one or more selected flights." :
                              ("already_waiting".equals(error)) ? "You're already on the waiting list for a selected flight." :
                              "Reservation error." %></p>
    
        <p> Details:</p>
        <ul>
            <li>Airline ID: <%= airlineId %></li>
            <li>Flight Number: <%= flightNumber %></li>
            <li>Departure Date: <%= departureDate %></li>
        </ul>
<% } %>

    <br>
    <a href="searchFlights.jsp">Back to Search Flights</a>
    <a href="homeCustomer.jsp">Customer Home</a>
</body>
</html>
