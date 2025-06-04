<%@ page import="java.sql.*" %>
<%
    String custID = request.getParameter("cust_id");
    String status = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Post a Question</title>
    <style>
        body { font-family: Arial; }
        textarea { width: 400px; height: 100px; }
        .message { font-weight: bold; margin-bottom: 10px; }
    </style>
</head>
<body>

<h2>Post a Question to Customer Representative</h2>

<% if ("success".equals(status)) { %>
    <p class="message" style="color: green;">Your question has been submitted successfully.</p>
<% } else if ("error".equals(status)) { %>
    <p class="message" style="color: red;">There was an error submitting your question.</p>
<% } %>

<form action="postQuestion" method="post">
    <input type="hidden" name="cust_id" value="<%= custID %>">
    <label for="question">Your Question:</label><br>
    <textarea name="question" required></textarea><br><br>
    <input type="submit" value="Submit Question">
</form>

<h3>Your Questions and Responses</h3>

<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
        stmt = conn.prepareStatement("SELECT question_text, answer FROM inquiry WHERE custID = ?");
        stmt.setInt(1, Integer.parseInt(custID));
        rs = stmt.executeQuery();

        while (rs.next()) {
            String question = rs.getString("question_text");
            String answer = rs.getString("answer");
%>
    <div class="qa-box">
        <p><strong>Question:</strong> <%= question %></p>
        <p><strong>Response:</strong> <%= (answer != null && !answer.trim().isEmpty()) ? answer : "Awaiting response..." %></p>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading Q&A: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>


<br>
<a href="homeCustomer.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px;">Home</a>

</body>
</html>