package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class JoinWaitingListServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int custID = Integer.parseInt(request.getParameter("cust_id"));
        String flight1 = request.getParameter("flight_number_1");
        String flight2 = request.getParameter("flight_number_2");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            if (flight1 != null && flight2 != null) {
                // Round trip — process both flights
                for (int i = 1; i <= 2; i++) {
                    String airlineId = request.getParameter("airline_id_" + i);
                    int flightNumber = Integer.parseInt(request.getParameter("flight_number_" + i));
                    String departureDate = request.getParameter("departure_date_" + i);

                    // Check if already on the list
                    PreparedStatement checkStmt = conn.prepareStatement(
                        "SELECT * FROM WaitingList WHERE airline_id = ? AND flight_number = ? AND departure_date = ? AND custID = ?"
                    );
                    checkStmt.setString(1, airlineId);
                    checkStmt.setInt(2, flightNumber);
                    checkStmt.setDate(3, Date.valueOf(departureDate));
                    checkStmt.setInt(4, custID);
                    ResultSet checkRs = checkStmt.executeQuery();

                    if (checkRs.next()) {
                        request.setAttribute("error", "already_waiting");
                        request.setAttribute("airline_id", airlineId);
                        request.setAttribute("flight_number", flightNumber);
                        request.setAttribute("departure_date", departureDate);
                        request.setAttribute("cust_id", custID);

                        RequestDispatcher dispatcher = request.getRequestDispatcher("sendDuplicateBooking.jsp");
                        dispatcher.forward(request, response);
                        conn.close();
                        return;
                    }

                    // Get next priority
                    int priority = 1;
                    PreparedStatement maxStmt = conn.prepareStatement(
                        "SELECT MAX(priority_number) FROM WaitingList WHERE airline_id = ? AND flight_number = ? AND departure_date = ?"
                    );
                    maxStmt.setString(1, airlineId);
                    maxStmt.setInt(2, flightNumber);
                    maxStmt.setDate(3, Date.valueOf(departureDate));
                    ResultSet rs = maxStmt.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        priority = rs.getInt(1) + 1;
                    }

                    // Insert
                    PreparedStatement insertStmt = conn.prepareStatement(
                        "INSERT INTO WaitingList (airline_id, flight_number, departure_date, custID, priority_number) " +
                        "VALUES (?, ?, ?, ?, ?)"
                    );
                    insertStmt.setString(1, airlineId);
                    insertStmt.setInt(2, flightNumber);
                    insertStmt.setDate(3, Date.valueOf(departureDate));
                    insertStmt.setInt(4, custID);
                    insertStmt.setInt(5, priority);
                    insertStmt.executeUpdate();
                }

                conn.close();
                response.sendRedirect("waitingList.jsp?cust_id=" + custID);

            } else {
                // One-way original logic
                String airlineId = request.getParameter("airline_id");
                int flightNumber = Integer.parseInt(request.getParameter("flight_number"));
                String departureDate = request.getParameter("departure_date");

                // Check
                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT * FROM WaitingList WHERE airline_id = ? AND flight_number = ? AND departure_date = ? AND custID = ?"
                );
                checkStmt.setString(1, airlineId);
                checkStmt.setInt(2, flightNumber);
                checkStmt.setDate(3, Date.valueOf(departureDate));
                checkStmt.setInt(4, custID);
                ResultSet checkRs = checkStmt.executeQuery();

                if (checkRs.next()) {
                    request.setAttribute("error", "already_waiting");
                    request.setAttribute("airline_id", airlineId);
                    request.setAttribute("flight_number", flightNumber);
                    request.setAttribute("departure_date", departureDate);
                    request.setAttribute("cust_id", custID);

                    RequestDispatcher dispatcher = request.getRequestDispatcher("sendDuplicateBooking.jsp");
                    dispatcher.forward(request, response);
                    conn.close();
                    return;
                }

                // Priority
                int priority = 1;
                PreparedStatement maxStmt = conn.prepareStatement(
                    "SELECT MAX(priority_number) FROM WaitingList WHERE airline_id = ? AND flight_number = ? AND departure_date = ?"
                );
                maxStmt.setString(1, airlineId);
                maxStmt.setInt(2, flightNumber);
                maxStmt.setDate(3, Date.valueOf(departureDate));
                ResultSet rs = maxStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    priority = rs.getInt(1) + 1;
                }

                // Insert
                PreparedStatement insertStmt = conn.prepareStatement(
                    "INSERT INTO WaitingList (airline_id, flight_number, departure_date, custID, priority_number) " +
                    "VALUES (?, ?, ?, ?, ?)"
                );
                insertStmt.setString(1, airlineId);
                insertStmt.setInt(2, flightNumber);
                insertStmt.setDate(3, Date.valueOf(departureDate));
                insertStmt.setInt(4, custID);
                insertStmt.setInt(5, priority);
                insertStmt.executeUpdate();

                conn.close();
               // response.sendRedirect("waitingList.jsp?cust_id=" + custID);
                response.sendRedirect("waitingList.jsp?cust_id=" + custID +
                        "&airline_id=" + airlineId +
                        "&flight_number=" + flightNumber +
                        "&departure_date=" + departureDate);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error joining waiting list: " + e.getMessage());
        }
    }
}
