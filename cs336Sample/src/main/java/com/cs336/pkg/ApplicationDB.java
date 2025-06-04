package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ApplicationDB {

    // Constructor
    public ApplicationDB() {
    }

    public Connection getConnection() {
        Connection connection = null;

        String connectionUrl = "jdbc:mysql://localhost:3306/flight_project?autoReconnect=true&useSSL=false&serverTimezone=UTC";
        String username = "root";
        String password = "pancakes1123!";  // Use your real password here

        try {
            // Load the MySQL JDBC driver (optional in recent JDBC versions but kept for compatibility)
        	Class.forName("com.mysql.jdbc.Driver");

            // Establish the connection
            connection = DriverManager.getConnection(connectionUrl, username, password);

        } catch (ClassNotFoundException e) {
            System.out.println("JDBC Driver not found.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Database connection failed.");
            e.printStackTrace();
        }

        return connection;
    }

    public void closeConnection(Connection connection) {
        try {
            if (connection != null && !connection.isClosed())
                connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        ApplicationDB dao = new ApplicationDB();
        Connection connection = dao.getConnection();
        System.out.println(connection != null ? "Connection successful!" : "Connection failed.");
        dao.closeConnection(connection);
    }
}
