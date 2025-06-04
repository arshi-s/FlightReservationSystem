package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;

public class MakeReservationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int custID = Integer.parseInt(request.getParameter("cust_id"));
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT MAX(ticketID) FROM FlightTicket");
            int newTicketID = (rs.next() && rs.getInt(1) != 0) ? rs.getInt(1) + 1 : 1;
            rs.close();

            // Check if it's a round-trip booking
            String selectedRow = request.getParameter("selectedRow");
            String roundTripInfo = (selectedRow != null) ? request.getParameter("flightinfo_" + selectedRow) : null;

            if (roundTripInfo != null) {
                String selectedClass = request.getParameter("class_" + selectedRow);
                String[] parts = roundTripInfo.split("\\|");
                String depFlight = parts[0];
                String depAirline = parts[1];
                String depDate = parts[2];
                String retFlight = parts[3];
                String retAirline = parts[4];
                String retDate = parts[5];

                // Duplicate booking check
                for (int i = 0; i < 2; i++) {
                    String flightNum = (i == 0) ? depFlight : retFlight;
                    String airline = (i == 0) ? depAirline : retAirline;
                    String date = (i == 0) ? depDate : retDate;
                    PreparedStatement dup = conn.prepareStatement(
                        "SELECT 1 FROM FlightTicket FT JOIN FlightTicketFlights FTF ON FT.ticketID = FTF.ticketID " +
                        "WHERE FT.custID = ? AND FTF.flight_number = ? AND FTF.airline_id = ? AND FTF.departure_date = ?");
                    dup.setInt(1, custID);
                    dup.setInt(2, Integer.parseInt(flightNum));
                    dup.setString(3, airline);
                    dup.setDate(4, Date.valueOf(date));
                    ResultSet drs = dup.executeQuery();
                    if (drs.next()) {
                        request.setAttribute("error", "duplicate");
                        request.setAttribute("airline_id", airline);
                        request.setAttribute("flight_number", flightNum);
                        request.setAttribute("departure_date", date);
                        request.setAttribute("cust_id", custID);
                        RequestDispatcher dispatcher = request.getRequestDispatcher("sendDuplicateBooking.jsp");
                        dispatcher.forward(request, response);
                        conn.close();
                        return;
                    }
                    drs.close();
                    dup.close();
                }

                // Check availability
                boolean full = false;
                String[][] flights = {
                    {depFlight, depAirline, depDate},
                    {retFlight, retAirline, retDate}
                };
                for (String[] f : flights) {
                    PreparedStatement seat = conn.prepareStatement(
                        "SELECT seat_availability FROM FlightAvailability WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?");
                    seat.setInt(1, Integer.parseInt(f[0]));
                    seat.setString(2, f[1]);
                    seat.setDate(3, Date.valueOf(f[2]));
                    ResultSet srs = seat.executeQuery();
                    if (srs.next() && srs.getInt("seat_availability") <= 0) {
                        full = true;
                    }
                    srs.close();
                    seat.close();
                }

                if (full) {
                    request.setAttribute("error", "full");
                    request.setAttribute("cust_id", custID);
                    request.setAttribute("flightinfo", roundTripInfo);
                    RequestDispatcher dispatcher = request.getRequestDispatcher("waitingList.jsp");
                    dispatcher.forward(request, response);
                    conn.close();
                    return;
                }

                // Insert flight ticket
                PreparedStatement ticketStmt = conn.prepareStatement(
                    "INSERT INTO FlightTicket (ticketID, triptype, class, totalfare, purchasedate, purchasetime, bookingfee, custID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                double totalFare = 0.0;
                for (String[] f : flights) {
                    PreparedStatement p = conn.prepareStatement("SELECT price FROM Flights WHERE flight_number = ? AND airline_id = ?");
                    p.setInt(1, Integer.parseInt(f[0]));
                    p.setString(2, f[1]);
                    ResultSet prs = p.executeQuery();
                    if (prs.next()) {
                        double base = prs.getDouble("price");
                        if (selectedClass.equals("business")) base *= 1.5;
                        else if (selectedClass.equals("first")) base *= 2.0;
                        totalFare += base;
                    }
                    prs.close();
                    p.close();
                }

                ticketStmt.setInt(1, newTicketID);
                ticketStmt.setString(2, "RoundTrip");
                ticketStmt.setString(3, selectedClass);
                ticketStmt.setDouble(4, totalFare + 20);
                ticketStmt.setDate(5, Date.valueOf(LocalDate.now()));
                ticketStmt.setTime(6, Time.valueOf(LocalTime.now()));
                ticketStmt.setInt(7, 20);
                ticketStmt.setInt(8, custID);
                ticketStmt.executeUpdate();

                for (String[] f : flights) {
                    int flightNum = Integer.parseInt(f[0]);
                    String airlineID = f[1];
                    String date = f[2];

                    PreparedStatement timeStmt = conn.prepareStatement("SELECT dept_time FROM Flights WHERE flight_number = ? AND airline_id = ?");
                    timeStmt.setInt(1, flightNum);
                    timeStmt.setString(2, airlineID);
                    ResultSet trs = timeStmt.executeQuery();
                    Time deptTime = trs.next() ? trs.getTime("dept_time") : Time.valueOf("00:00:00");
                    trs.close();
                    timeStmt.close();

                    PreparedStatement insertLeg = conn.prepareStatement(
                        "INSERT INTO FlightTicketFlights (ticketID, flight_number, airline_id, departure_date, departure_time, seatnum, class) VALUES (?, ?, ?, ?, ?, ?, ?)");
                    insertLeg.setInt(1, newTicketID);
                    insertLeg.setInt(2, flightNum);
                    insertLeg.setString(3, airlineID);
                    insertLeg.setDate(4, Date.valueOf(date));
                    insertLeg.setTime(5, deptTime);
                    insertLeg.setInt(6, 1);
                    insertLeg.setString(7, selectedClass);
                    insertLeg.executeUpdate();

                    PreparedStatement updateSeats = conn.prepareStatement(
                        "UPDATE FlightAvailability SET seat_availability = seat_availability - 1 WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?");
                    updateSeats.setInt(1, flightNum);
                    updateSeats.setString(2, airlineID);
                    updateSeats.setDate(3, Date.valueOf(date));
                    updateSeats.executeUpdate();
                }

                conn.close();
                response.sendRedirect("ticketConfirm.jsp?cust_id=" + custID);
                return;
            }

            // One-Way Booking (from displayFlight.jsp)
            String airlineId = request.getParameter("airline_id_0");
            String flightNum = request.getParameter("flight_number_0");
            String depDate = request.getParameter("departure_date_0");
            String ticketClass = request.getParameter("ticket_class_0");

            // Check duplicate
            PreparedStatement dup = conn.prepareStatement(
                "SELECT 1 FROM FlightTicket FT JOIN FlightTicketFlights FTF ON FT.ticketID = FTF.ticketID " +
                "WHERE FT.custID = ? AND FTF.flight_number = ? AND FTF.airline_id = ? AND FTF.departure_date = ?");
            dup.setInt(1, custID);
            dup.setInt(2, Integer.parseInt(flightNum));
            dup.setString(3, airlineId);
            dup.setDate(4, Date.valueOf(depDate));
            ResultSet dupRs = dup.executeQuery();
            if (dupRs.next()) {
                request.setAttribute("error", "duplicate");
                request.setAttribute("airline_id", airlineId);
                request.setAttribute("flight_number", flightNum);
                request.setAttribute("departure_date", depDate);
                request.setAttribute("cust_id", custID);
                RequestDispatcher dispatcher = request.getRequestDispatcher("sendDuplicateBooking.jsp");
                dispatcher.forward(request, response);
                conn.close();
                return;
            }
            dupRs.close();
            dup.close();

            // Check availability
            boolean full = false;
            PreparedStatement seat = conn.prepareStatement(
                "SELECT seat_availability FROM FlightAvailability WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?");
            seat.setInt(1, Integer.parseInt(flightNum));
            seat.setString(2, airlineId);
            seat.setDate(3, Date.valueOf(depDate));
            ResultSet srs = seat.executeQuery();
            if (srs.next() && srs.getInt("seat_availability") <= 0) full = true;
            srs.close();
            seat.close();

            if (full) {
                request.setAttribute("error", "full");
                request.setAttribute("airline_id", airlineId);
                request.setAttribute("flight_number", flightNum);
                request.setAttribute("departure_date", depDate);
                request.setAttribute("cust_id", custID);
                RequestDispatcher dispatcher = request.getRequestDispatcher("waitingList.jsp");
                dispatcher.forward(request, response);
                conn.close();
                return;
            }

            PreparedStatement priceStmt = conn.prepareStatement("SELECT price FROM Flights WHERE flight_number = ? AND airline_id = ?");
            priceStmt.setInt(1, Integer.parseInt(flightNum));
            priceStmt.setString(2, airlineId);
            ResultSet prs = priceStmt.executeQuery();
            double basePrice = prs.next() ? prs.getDouble("price") : 0.0;
            prs.close();
            priceStmt.close();

            if (ticketClass.equals("business")) basePrice *= 1.5;
            else if (ticketClass.equals("first")) basePrice *= 2.0;

            PreparedStatement ticketStmt = conn.prepareStatement(
                "INSERT INTO FlightTicket (ticketID, triptype, class, totalfare, purchasedate, purchasetime, bookingfee, custID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            ticketStmt.setInt(1, newTicketID);
            ticketStmt.setString(2, "OneWay");
            ticketStmt.setString(3, ticketClass);
            ticketStmt.setDouble(4, basePrice + 20);
            ticketStmt.setDate(5, Date.valueOf(LocalDate.now()));
            ticketStmt.setTime(6, Time.valueOf(LocalTime.now()));
            ticketStmt.setInt(7, 20);
            ticketStmt.setInt(8, custID);
            ticketStmt.executeUpdate();

            PreparedStatement timeStmt = conn.prepareStatement("SELECT dept_time FROM Flights WHERE flight_number = ? AND airline_id = ?");
            timeStmt.setInt(1, Integer.parseInt(flightNum));
            timeStmt.setString(2, airlineId);
            ResultSet trs = timeStmt.executeQuery();
            Time deptTime = trs.next() ? trs.getTime("dept_time") : Time.valueOf("00:00:00");
            trs.close();
            timeStmt.close();

            PreparedStatement legStmt = conn.prepareStatement(
                "INSERT INTO FlightTicketFlights (ticketID, flight_number, airline_id, departure_date, departure_time, seatnum, class) VALUES (?, ?, ?, ?, ?, ?, ?)");
            legStmt.setInt(1, newTicketID);
            legStmt.setInt(2, Integer.parseInt(flightNum));
            legStmt.setString(3, airlineId);
            legStmt.setDate(4, Date.valueOf(depDate));
            legStmt.setTime(5, deptTime);
            legStmt.setInt(6, 1);
            legStmt.setString(7, ticketClass);
            legStmt.executeUpdate();

            PreparedStatement decStmt = conn.prepareStatement(
                "UPDATE FlightAvailability SET seat_availability = seat_availability - 1 WHERE flight_number_avail = ? AND airline_id_avail = ? AND departure_date = ?");
            decStmt.setInt(1, Integer.parseInt(flightNum));
            decStmt.setString(2, airlineId);
            decStmt.setDate(3, Date.valueOf(depDate));
            decStmt.executeUpdate();

            conn.close();
            response.sendRedirect("ticketConfirm.jsp?cust_id=" + custID);
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Reservation error: " + e.getMessage());
        }
    }
}
