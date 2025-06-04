package com.cs336.pkg;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class SubmitReplyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String inquiryIdStr = request.getParameter("inquiryID");
        String reply = request.getParameter("answer"); // ✅ use "answer" instead of answer_status
        String repIdStr = request.getParameter("repID");

        if (inquiryIdStr == null || reply == null || reply.trim().isEmpty() || repIdStr == null) {
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<html><body>");
            out.println("<h3 style='color:red;'>Missing inquiry ID, rep ID, or reply message.</h3>");
            out.println("<a href='replyToQuestions.jsp'>Back to Inquiries</a>");
            out.println("</body></html>");
            return;
        }

        try {
            int inquiryId = Integer.parseInt(inquiryIdStr);
            int repId = Integer.parseInt(repIdStr);

            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!"
            );

            // ✅ Properly update the actual answer, mark as answered, assign rep
            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE inquiry SET answer = ?, answer_status = 'answered', custrepID = ? WHERE inquiryID = ?"
            );
            stmt.setString(1, reply);
            stmt.setInt(2, repId);
            stmt.setInt(3, inquiryId);

            int rowsUpdated = stmt.executeUpdate();
            conn.close();

            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<html><head><title>Reply Submitted</title></head><body>");
            if (rowsUpdated > 0) {
                out.println("<h2 style='color:green;'>Reply successfully submitted!</h2>");
            } else {
                out.println("<h2 style='color:red;'>Failed to submit reply. Inquiry may not exist.</h2>");
            }
            out.println("<br><a href='homeCustomerRep.jsp'>Return to Home</a>");
            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
