<%@ page import="java.sql.*" %>
<%
   String message = request.getParameter("message");
%>
<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Maintain Airport</title>
   <style>
       body { font-family: Arial; padding: 20px; }
       table, th, td { border: 1px solid #ccc; border-collapse: collapse; padding: 8px; }
       th { background-color: #f2f2f2; }
       .form-section { margin-top: 30px; }
   </style>
</head>
<body>
   <h2>Manage Airports</h2>
   <% if (message != null) { %>
       <p style="color: green;"><%= message %></p>
   <% } %>
   <!-- Display all airports -->
   <table>
       <tr>
           <th>Airport ID</th>
           <th>Airport Name</th>
       </tr>
       <%
           try (
               Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
               PreparedStatement stmt = conn.prepareStatement("SELECT * FROM airport");
               ResultSet rs = stmt.executeQuery();
           ) {
               Class.forName("com.mysql.jdbc.Driver");
               while (rs.next()) {
       %>
       <tr>
           <td><%= rs.getString("airport_id") %></td>
           <td><%= rs.getString("airport_name") %></td>
       </tr>
       <%
               }
           } catch (Exception e) {
               out.println("<p style='color:red;'>Error loading airports: " + e.getMessage() + "</p>");
           }
       %>
   </table>
   <!-- Add Airport -->
   <div class="form-section">
       <h3>Add Airport</h3>
       <form action="maintainAirport" method="post">
           <input type="hidden" name="action" value="add">
           Airport ID (3-letter): <input type="text" name="airport_id" maxlength="3" required>
           Airport Name: <input type="text" name="airport_name" required>
           <input type="submit" value="Add">
       </form>
   </div>
   <!-- Edit Airport -->
   <div class="form-section">
       <h3>Edit Airport</h3>
       <form action="maintainAirport" method="post">
           <input type="hidden" name="action" value="edit">
           Select Airport ID:
           <select name="airport_id" required>
               <%
                   try (
                       Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                       PreparedStatement stmt = conn.prepareStatement("SELECT airport_id FROM airport");
                       ResultSet rs = stmt.executeQuery();
                   ) {
                       while (rs.next()) {
               %>
                   <option value="<%= rs.getString("airport_id") %>"><%= rs.getString("airport_id") %></option>
               <%
                       }
                   } catch (Exception e) {
                       out.println("<option>Error loading airports</option>");
                   }
               %>
           </select>
           New Name: <input type="text" name="airport_name" required>
           <input type="submit" value="Update">
       </form>
   </div>
   <!-- Delete Airport -->
   <div class="form-section">
       <h3>Delete Airport</h3>
       <form action="maintainAirport" method="post">
           <input type="hidden" name="action" value="delete">
           Select Airport ID:
           <select name="airport_id" required>
               <%
                   try {
                       Class.forName("com.mysql.jdbc.Driver");
                       Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/flight_project", "root", "pancakes1123!");
                       PreparedStatement stmt = conn.prepareStatement(
                           "SELECT a.airport_id FROM airport a "+
                           "LEFT JOIN flights f1 ON a.airport_id = f1.depart_airportID "+
                           "LEFT JOIN flights f2 ON a.airport_id = f2.arrival_airportID "+
                           "LEFT JOIN operatesin o ON a.airport_id = o.airport_id "+
                           "WHERE f1.depart_airportID IS NULL AND f2.arrival_airportID IS NULL AND o.airport_id IS NULL");
                       ResultSet rs = stmt.executeQuery();
                       boolean found = false;
                       while (rs.next()) {
                           found = true;
               %>
               <option value="<%= rs.getString("airport_id") %>"><%= rs.getString("airport_id") %></option>
               <%
                       }
                       if (!found) {
                           out.println("<option disabled>No deletable airports available</option>");
                       }
                       conn.close();
                   } catch (Exception e) {
                       out.println("<option>Error loading deletable airports</option>");
                   }
               %>
           </select>
           <input type="submit" value="Delete">
       </form>
   </div>
   <br><a href="homeCustomerRep.jsp">Back to Home</a>
</body>
</html>
