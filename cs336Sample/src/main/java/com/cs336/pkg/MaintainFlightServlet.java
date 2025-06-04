package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class MaintainFlightServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        Connection conn = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            if ("add".equals(action)) {
                PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO flights (flight_number, type, aircraft_id, airline_id, dept_time, arrival_time, depart_airportID, arrival_airportID, stops, price) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

                stmt.setInt(1, Integer.parseInt(request.getParameter("flight_number")));
                stmt.setString(2, request.getParameter("type"));
                stmt.setInt(3, Integer.parseInt(request.getParameter("aircraft_id")));
                stmt.setString(4, request.getParameter("airline_id"));

                // Convert time strings to java.sql.Time
                stmt.setTime(5, java.sql.Time.valueOf(request.getParameter("dept_time") + ":00"));
                stmt.setTime(6, java.sql.Time.valueOf(request.getParameter("arrival_time") + ":00"));

                stmt.setString(7, request.getParameter("depart_airportID"));
                stmt.setString(8, request.getParameter("arrival_airportID"));
                stmt.setInt(9, Integer.parseInt(request.getParameter("stops")));
                stmt.setDouble(10, Double.parseDouble(request.getParameter("price")));
                stmt.executeUpdate();
                stmt.close();
                response.sendRedirect("maintainFlight.jsp?message=Flight added successfully.");

            } else if ("update".equals(action)) {
                PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE flights SET type=?, aircraft_id=?, dept_time=?, arrival_time=?, depart_airportID=?, arrival_airportID=?, stops=?, price=? " +
                    "WHERE flight_number=? AND airline_id=?");

                stmt.setString(1, request.getParameter("type"));
                stmt.setInt(2, Integer.parseInt(request.getParameter("aircraft_id")));

                stmt.setTime(3, java.sql.Time.valueOf(request.getParameter("dept_time") + ":00"));
                stmt.setTime(4, java.sql.Time.valueOf(request.getParameter("arrival_time") + ":00"));

                stmt.setString(5, request.getParameter("depart_airportID"));
                stmt.setString(6, request.getParameter("arrival_airportID"));
                stmt.setInt(7, Integer.parseInt(request.getParameter("stops")));
                stmt.setDouble(8, Double.parseDouble(request.getParameter("price")));
                stmt.setInt(9, Integer.parseInt(request.getParameter("flight_number")));
                stmt.setString(10, request.getParameter("airline_id"));
                stmt.executeUpdate();
                stmt.close();
                response.sendRedirect("maintainFlight.jsp?message=Flight updated successfully.");

            } else if ("delete".equals(action)) {
                String selectedParam = request.getParameter("selectedFlight");
                if (selectedParam == null) {
                    response.sendRedirect("maintainFlight.jsp?message=Error: No flight selected for deletion.");
                    return;
                }
                String[] selected = selectedParam.split("_");
                int flightNumber = Integer.parseInt(selected[0]);
                String airlineId = selected[1];

                // First delete from flightdays
                PreparedStatement delFD = conn.prepareStatement("DELETE FROM flightdays WHERE flight_number = ? AND airline_id = ?");
                delFD.setInt(1, flightNumber);
                delFD.setString(2, airlineId);
                delFD.executeUpdate();
                delFD.close();

                // Delete from flightavailability
                PreparedStatement delFA = conn.prepareStatement("DELETE FROM FlightAvailability WHERE flight_number_avail = ? AND airline_id_avail = ?");
                delFA.setInt(1, flightNumber);
                delFA.setString(2, airlineId);
                delFA.executeUpdate();
                delFA.close();

                // Delete from flights
                PreparedStatement stmt = conn.prepareStatement("DELETE FROM flights WHERE flight_number = ? AND airline_id = ?");
                stmt.setInt(1, flightNumber);
                stmt.setString(2, airlineId);
                stmt.executeUpdate();
                stmt.close();

                response.sendRedirect("maintainFlight.jsp?message=Flight deleted successfully.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("maintainFlight.jsp?message=Error: " + e.getMessage());
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}
