	<%@ page import="java.sql.*" %>
<%
    String airlineId = request.getParameter("airline_id");
    String flightNumber = request.getParameter("flight_number");
    String departureDate = request.getParameter("departure_date");
    String custID = request.getParameter("cust_id");

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT W.custID, C.fname, C.lname, W.priority_number " +
            "FROM WaitingList W JOIN Customer C ON W.custID = C.custID " +
            "WHERE W.airline_id = ? AND W.flight_number = ? AND W.departure_date = ? " +
            "ORDER BY W.priority_number ASC"
        );
        stmt.setString(1, airlineId);
        stmt.setString(2, flightNumber);
        stmt.setString(3, departureDate);

        ResultSet rs = stmt.executeQuery();

%>
<h2>Waiting List for Flight <%= airlineId %> <%= flightNumber %> on <%= departureDate %></h2>
<table border="1">
    <tr><th>Position</th><th>Customer</th><th>Customer ID</th></tr>
<%
    while (rs.next()) {
        int pos = rs.getInt("priority_number");
        String name = rs.getString("fname") + " " + rs.getString("lname");
        int id = rs.getInt("custID");

        %>
        <tr<%= (id == Integer.parseInt(custID)) ? " style='font-weight:bold;color:blue'" : "" %>>
            <td><%= pos %></td>
            <td><%= name %></td>
            <td><%= id %></td>
        </tr>
        <%
    }

        conn.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
%>
</table>

<a href="homeCustomer.jsp" style="display:inline-block; padding:5px 15px; background:#007BFF; color:white; text-decoration:none; border-radius:4px; font-weight:bold;">Home</a>
