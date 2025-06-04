package com.cs336.pkg;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class MaintainAircraftServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int aircraftID = Integer.parseInt(request.getParameter("aircraft_id"));
        Connection conn = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            if ("add".equals(action)) {
                int seatCapacity = Integer.parseInt(request.getParameter("seat_capacity"));
                String airlineID = request.getParameter("airline_id");

                PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO aircraft (aircraft_id, seat_capacity, airline_id) VALUES (?, ?, ?)");
                stmt.setInt(1, aircraftID);
                stmt.setInt(2, seatCapacity);
                stmt.setString(3, airlineID);
                stmt.executeUpdate();
                stmt.close();

            } else if ("delete".equals(action)) {
                PreparedStatement stmt = conn.prepareStatement(
                        "DELETE FROM aircraft WHERE aircraft_id = ?");
                stmt.setInt(1, aircraftID);
                stmt.executeUpdate();
                stmt.close();

            } else if ("edit".equals(action)) {
            	 String airlineID = request.getParameter("airline_id");
                int seatCapacity = Integer.parseInt(request.getParameter("seat_capacity"));
                PreparedStatement stmt = conn.prepareStatement(
                        "UPDATE aircraft SET seat_capacity = ? WHERE aircraft_id = ?");
                stmt.setInt(1, seatCapacity);
                stmt.setInt(2, aircraftID);
                stmt.executeUpdate();
                stmt.close();
            }

            response.sendRedirect("maintainAircraft.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException ignored) {}
        }
    }
}
