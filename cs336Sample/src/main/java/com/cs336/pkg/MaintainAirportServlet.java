package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class MaintainAirportServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String airportId = request.getParameter("airport_id");
        String airportName = request.getParameter("airport_name");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            String message = "";

            switch (action) {
                case "add":
                    PreparedStatement addStmt = conn.prepareStatement(
                        "INSERT INTO airport (airport_id, airport_name) VALUES (?, ?)"
                    );
                    addStmt.setString(1, airportId);
                    addStmt.setString(2, airportName);
                    addStmt.executeUpdate();
                    message = "Airport added successfully.";
                    break;

                case "edit":
                    PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE airport SET airport_name = ? WHERE airport_id = ?"
                    );
                    updateStmt.setString(1, airportName);
                    updateStmt.setString(2, airportId);
                    updateStmt.executeUpdate();
                    message = "Airport updated successfully.";
                    break;

                case "delete":
                    // Check for flight references before deletion
                    PreparedStatement checkFlights = conn.prepareStatement(
                        "SELECT COUNT(*) FROM flights WHERE depart_airportID = ? OR arrival_airportID = ?"
                    );
                    checkFlights.setString(1, airportId);
                    checkFlights.setString(2, airportId);
                    ResultSet rsCheck = checkFlights.executeQuery();
                    rsCheck.next();
                    int count = rsCheck.getInt(1);

                    if (count > 0) {
                        message = "Cannot delete airport. It is still used by one or more flights.";
                    } else {
                        PreparedStatement deleteStmt = conn.prepareStatement(
                            "DELETE FROM airport WHERE airport_id = ?"
                        );
                        deleteStmt.setString(1, airportId);
                        deleteStmt.executeUpdate();
                        message = "Airport deleted successfully.";
                    }
                    break;

                default:
                    message = "Invalid action.";
            }

            conn.close();
            response.sendRedirect("maintainAirport.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
