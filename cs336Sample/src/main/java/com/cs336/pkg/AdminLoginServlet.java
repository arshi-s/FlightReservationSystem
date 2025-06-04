package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AdminLoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
            PreparedStatement pst = con.prepareStatement("SELECT fname, lname FROM admin WHERE username = ? AND password = ?");
            pst.setString(1, username);
            pst.setString(2, password);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("fname", rs.getString("fname"));
                session.setAttribute("lname", rs.getString("lname"));
                response.sendRedirect("homeAdmin.jsp");
            } else {
                response.sendRedirect("adminLogin.jsp?error=Invalid%20credentials");
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}