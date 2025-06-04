<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
    <h1>Welcome to the Flight Reservation System - Customer Home</h1>

    <h2>Welcome, <%= session.getAttribute("fname") %> <%= session.getAttribute("lname") %></h2>
    <p>Your Customer ID: <%= session.getAttribute("custID") %></p>

    <ul>
        <li><a href="searchFlights.jsp?cust_id=<%= session.getAttribute("custID") %>">Search Flights</a></li>
        <li><a href="cancelReservation.jsp?cust_id=<%= session.getAttribute("custID") %>">Cancel Reservation</a></li>
        <li><a href="searchQA?cust_id=<%= session.getAttribute("custID") %>">Browse and Search Q and A</a></li>
        <li><a href="postQuestion.jsp?cust_id=<%= session.getAttribute("custID") %>">Post a Question</a></li>
        <li><a href="viewPast?cust_id=<%= session.getAttribute("custID") %>">View Past Flights</a></li>
        <li><a href="viewUpcoming?cust_id=<%= session.getAttribute("custID") %>">View Upcoming Flights</a></li>
        <li><a href="viewWaitingStatus.jsp?cust_id=<%= session.getAttribute("custID") %>">View Waiting List Status</a></li>
    </ul>

    <a href="custLogin.jsp">Logout</a>
    <br><a href="home.jsp">Back to Main Home</a>
</body>
</html>
