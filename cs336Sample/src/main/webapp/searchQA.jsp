<%@ page import="java.util.*, java.sql.*" %>
<%
    List<String[]> results = (List<String[]>) request.getAttribute("results");
    String keyword = (String) request.getAttribute("keyword");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Search FAQs</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 80%; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 10px; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>Search FAQs</h2>

    <form action="searchQA" method="get">
        <input type="text" name="search_term" placeholder="Enter keyword" value="<%= (keyword != null ? keyword : "") %>">
        <input type="submit" value="Search">
    </form>

    <%
        if (results != null && !results.isEmpty()) {
    %>
        <table>
            <tr>
                <th>Question</th>
                <th>Answer</th>
            </tr>
            <%
                for (String[] row : results) {
            %>
                <tr>
                    <td><%= row[0] %></td>
                    <td><%= row[1] %></td>
                </tr>
            <%
                }
            %>
        </table>
    <%
        } else {
    %>
        <p>No FAQs found.</p>
    <%
        }
    %>

    <br>
    <a href="homeCustomer.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px;">Home</a>
</body>
</html>