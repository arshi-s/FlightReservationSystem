package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class ViewUpcomingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        //int custID = 1; // Replace with session-based custID when ready
    	int custID = Integer.parseInt(request.getParameter("cust_id"));


        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            PreparedStatement stmt = conn.prepareStatement(
                "SELECT FT.ticketID, FT.purchasedate, F.airline_id, F.flight_number, " +
                "FTF.departure_date, F.depart_airportID, F.arrival_airportID " +
                "FROM FlightTicket FT " +
                "JOIN FlightTicketFlights FTF ON FT.ticketID = FTF.ticketID " +
                "JOIN Flights F ON FTF.flight_number = F.flight_number AND FTF.airline_id = F.airline_id " +
                "WHERE FT.custID = ? AND FTF.departure_date >= CURDATE() " +
                "ORDER BY FTF.departure_date ASC"
            );

            stmt.setInt(1, custID);
            ResultSet rs = stmt.executeQuery();

            request.setAttribute("results", rs);
            RequestDispatcher rd = request.getRequestDispatcher("viewUpcoming.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error retrieving upcoming flights: " + e.getMessage());
        }
    }
}