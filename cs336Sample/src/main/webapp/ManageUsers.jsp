<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*,java.util.*,java.sql.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>

<%
    // Check if the user is logged in and has the 'admin' role
    //String userRole = (String) session.getAttribute("userRole");
    String userRole = "admin";
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="admin-content">
    <!-- Back to Admin Dashboard Button -->
        <a href="homeAdmin.jsp">
            <button>Back to Admin Dashboard</button>
        </a>
        <h2>Manage Users</h2>

        <div class="user-actions">
            <form method="get">
                <label for="action">Choose an action:</label>
                <select name="action" id="action" onchange="this.form.submit()">
                    <option value="">-- Select --</option>
                    <option value="add" <%= "add".equals(request.getParameter("action")) ? "selected" : "" %>>Add User</option>
                    <option value="edit" <%= "edit".equals(request.getParameter("action")) ? "selected" : "" %>>Edit User</option>
                    <option value="delete" <%= "delete".equals(request.getParameter("action")) ? "selected" : "" %>>Delete User</option>
                </select>
            </form>
        </div>

        <div class="action-form">
            <%
                String action = request.getParameter("action");
                if ("add".equals(action)) {
            %>
                <jsp:include page="AddUser.jsp" />
            <%
                } else if ("edit".equals(action)) {
            %>
                <jsp:include page="edit_user.jsp" />
            <%
                } else if ("delete".equals(action)) {
            %>
                <jsp:include page="delete_user.jsp" />
            <%
                }
            %>
        </div>
    </div>
</body>
</html>