package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;

public class SearchQAServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("search_term");
        List<String[]> results = new ArrayList<>();

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            PreparedStatement stmt;
            if (keyword != null && !keyword.trim().isEmpty()) {
                stmt = conn.prepareStatement(
                    "SELECT question, answer FROM FAQs WHERE question LIKE ? OR answer LIKE ?"
                );
                stmt.setString(1, "%" + keyword + "%");
                stmt.setString(2, "%" + keyword + "%");
            } else {
                // No keyword, show all
                stmt = conn.prepareStatement("SELECT question, answer FROM FAQs");
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                results.add(new String[] {
                    rs.getString("question"),
                    rs.getString("answer")
                });
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("results", results);
        request.setAttribute("keyword", keyword);
        RequestDispatcher dispatcher = request.getRequestDispatcher("searchQA.jsp");
        dispatcher.forward(request, response);
    }

    // Also allow POST to call doGet
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}