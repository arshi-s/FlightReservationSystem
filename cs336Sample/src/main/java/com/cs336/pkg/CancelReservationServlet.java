package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class CancelReservationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String ticketIdStr = request.getParameter("ticketID");
        String custIdStr = request.getParameter("cust_id");

        if (ticketIdStr == null || custIdStr == null) {
            response.sendRedirect("cancelReservation.jsp?status=error&cust_id=" + custIdStr);
            return;
        }

        int ticketID = Integer.parseInt(ticketIdStr);
        int custID = Integer.parseInt(custIdStr);

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            // Check ticket class
            PreparedStatement checkClassStmt = conn.prepareStatement(
                "SELECT class FROM FlightTicket WHERE ticketID = ? AND custID = ?"
            );
            checkClassStmt.setInt(1, ticketID);
            checkClassStmt.setInt(2, custID);
            ResultSet classRs = checkClassStmt.executeQuery();

            if (!classRs.next()) {
                conn.close();
                response.sendRedirect("cancelReservation.jsp?status=error&cust_id=" + custID);
                return;
            }

            String ticketClass = classRs.getString("class");

            if ("economy".equalsIgnoreCase(ticketClass)) {
                conn.close();
                response.sendRedirect("cancelReservation.jsp?status=denied&cust_id=" + custID);
                return;
            }

            // Get flight leg details
            PreparedStatement getFlightStmt = conn.prepareStatement(
                "SELECT flight_number, airline_id, departure_date FROM FlightTicketFlights WHERE ticketID = ?"
            );
            getFlightStmt.setInt(1, ticketID);
            ResultSet flightRs = getFlightStmt.executeQuery();

            int flightNum = -1;
            String airlineId = "";
            Date depDate = null;
            if (flightRs.next()) {
                flightNum = flightRs.getInt("flight_number");
                airlineId = flightRs.getString("airline_id");
                depDate = flightRs.getDate("departure_date");
            }

            // Delete the flight legs and the ticket
            PreparedStatement deleteFlight = conn.prepareStatement(
                "DELETE FROM FlightTicketFlights WHERE ticketID = ?");
            deleteFlight.setInt(1, ticketID);
            deleteFlight.executeUpdate();

            PreparedStatement deleteTicket = conn.prepareStatement(
                "DELETE FROM FlightTicket WHERE ticketID = ?");
            deleteTicket.setInt(1, ticketID);
            deleteTicket.executeUpdate();

            // Increment seat availability
            PreparedStatement updateAvail = conn.prepareStatement(
                "UPDATE FlightAvailability SET seat_availability = seat_availability + 1 " +
                "WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?"
            );
            updateAvail.setInt(1, flightNum);
            updateAvail.setString(2, airlineId);
            updateAvail.setDate(3, depDate);
            updateAvail.executeUpdate();

            // Check waiting list
            PreparedStatement getWait = conn.prepareStatement(
                "SELECT custID FROM WaitingList WHERE airline_id = ? AND flight_number = ? AND departure_date = ? ORDER BY priority_number ASC LIMIT 1"
            );
            getWait.setString(1, airlineId);
            getWait.setInt(2, flightNum);
            getWait.setDate(3, depDate);
            ResultSet waitRs = getWait.executeQuery();

            if (waitRs.next()) {
                conn.close();
                response.sendRedirect("cancelReservation.jsp?status=alerted&cust_id=" + custID);
                return;
            }

            conn.close();
            response.sendRedirect("cancelReservation.jsp?status=success&cust_id=" + custID);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Cancellation error: " + e.getMessage());
        }
    }
}


