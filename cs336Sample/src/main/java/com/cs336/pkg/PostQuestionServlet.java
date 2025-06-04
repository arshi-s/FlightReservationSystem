package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class PostQuestionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String question = request.getParameter("question");
        int custID = Integer.parseInt(request.getParameter("cust_id"));

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            PreparedStatement stmt = conn.prepareStatement(
            	    "INSERT INTO Inquiry (custID, question_text, answer_status) VALUES (?, ?, ?)"
            	);
            	stmt.setInt(1, custID);
            	stmt.setString(2, question);
            	stmt.setString(3, "unanswered");

            stmt.executeUpdate();
            conn.close();

            response.sendRedirect("postQuestion.jsp?cust_id=" + custID + "&status=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("postQuestion.jsp?cust_id=" + custID + "&status=error");
        }
    }
}