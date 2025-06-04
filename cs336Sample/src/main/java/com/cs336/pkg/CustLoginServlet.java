package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class CustLoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT c.custID, c.fname, c.lname FROM customer c " +
                "JOIN customeraccount ca ON c.custID = ca.custID " +
                "WHERE ca.username = ? AND ca.password = ?"
            );

            pstmt.setString(1, username);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("custID", rs.getInt("custID"));
                session.setAttribute("fname", rs.getString("fname"));
                session.setAttribute("lname", rs.getString("lname"));
                response.sendRedirect("homeCustomer.jsp");
            } else {
                request.setAttribute("errorMessage", "Invalid username or password.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("custLogin.jsp");
                dispatcher.forward(request, response);
            }

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
