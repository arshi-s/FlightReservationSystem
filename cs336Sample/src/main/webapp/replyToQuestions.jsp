<%@ page import="java.sql.*" %>
<%
    String custID = request.getParameter("custID");
int repID = (Integer) session.getAttribute("repid");

%>

<!DOCTYPE html>
<html>
<head>
    <title>Reply to Customer Questions</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .question-box { border: 1px solid #ccc; padding: 15px; margin-bottom: 25px; }
        textarea { width: 100%; height: 80px; margin-top: 10px; }
        input[type=submit] { margin-top: 10px; padding: 6px 15px; }
    </style>
</head>
<body>
    <h2>Reply to Questions from Customer ID: <%= custID %></h2>

<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

        stmt = conn.prepareStatement(
        		  "SELECT inquiryID, question_text FROM inquiry WHERE custID = ? AND answer_status = 'unanswered'"
        		);
        		stmt.setInt(1, Integer.parseInt(custID));
        rs = stmt.executeQuery();

        boolean hasResults = false;

        while (rs.next()) {
            hasResults = true;
            int inquiryID = rs.getInt("inquiryID");
            String question = rs.getString("question_text");
%>
        <div class="question-box">
            <p><strong>Question:</strong> <%= question %></p>
            <form method="post" action="submitReply">
    <input type="hidden" name="inquiryID" value="<%= inquiryID %>">
    <input type="hidden" name="repID" value="<%= repID %>">
    <label>Your Reply:</label><br>
    <textarea name="answer" required></textarea><br> <!-- ✅ FIXED name -->
    <input type="submit" value="Submit Reply">
</form>
            
            
        </div>
<%
        }

        if (!hasResults) {
%>
        <p>No unanswered questions for this customer.</p>
<%
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading inquiries: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<a href="homeCustomerRep.jsp?custID=<%= custID %>">Back to Home</a>
</body>
</html>
