<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        .card {
            background-color: white;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 0 8px rgba(0,0,0,0.1);
            width: 300px;
        }
        .link-btn {
            display: inline-block;
            margin: 10px 0;
            padding: 10px 20px;
            background-color: #0073e6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .link-btn:hover {
            background-color: #005bb5;
        }
    </style>
</head>
<body>
    <h1>Welcome to the Flight Reservation System - Admin Home</h1>
	 <h2>Admin Actions</h2>
	
	<div class="card">
    <a href="ManageUsers.jsp" class="link-btn">Manage Users</a><br>
    <a href="MonthlySalesReport.jsp">Sales Report</a><br>
    <a href="ReservationsList.jsp">Reservation List</a><br>
    <a href="RevenueReport.jsp">Revenue Summary</a><br>
    <a href="TopCustomer.jsp">Top Customers</a><br>
    <a href="MostActiveFlights.jsp">Active Flights</a><br>
	</div>
    
    <a href="adminLogin">Logout</a>
    <a href="home.jsp">Back to Main Home</a>
    
</body>
</html>