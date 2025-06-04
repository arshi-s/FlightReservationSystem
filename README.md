# FlightReservationSystem
# Online Travel Reservation System 

This is a full-stack web application that simulates an online airline reservation platform. The system supports three types of users: **Customers**, **Customer Representatives**, and **Admins**, each with their own set of privileges and workflows.

## Project Overview

The travel reservation system is modeled after real-world services like Expedia or Kayak. Users can search for one-way or round-trip flights (with flexible date options), make bookings, manage tickets, view histories, interact with customer service, and more. The backend is built using **Java (JSP/Servlets)** and **MySQL**, with **JDBC** handling database connectivity.

## User Roles & Functionalities

### Customer
- Search flights (one-way, round-trip, or flexible +/- 3 days)
- Make, view, and cancel reservations (restrictions apply to economy class)
- View past and upcoming trips
- Join a waitlist if flights are full
- Browse, ask, and search customer support questions

### Customer Representative
- Book or edit flight reservations for customers
- Add, edit, delete aircraft, airport, and flight data
- View waitlist for any flight
- Manage FAQs and respond to customer inquiries
- View flights arriving or departing from a specific airport

### Admin
- Add, edit, or delete customers and representatives
- View monthly sales reports
- Generate reservation lists (by customer or flight)
- View revenue reports by flight, airline, or customer
- Identify top revenue-generating customers
- View most active flights (based on tickets sold)

---

## Technologies Used

- **Frontend:** HTML, CSS, JSP
- **Backend:** Java (Servlets, JSP), JDBC
- **Database:** MySQL
- **Server:** Apache Tomcat
