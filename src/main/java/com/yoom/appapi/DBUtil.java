package com.yoom.appapi;

import org.json.JSONException;
import org.json.JSONObject;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DBUtil
{
    private static String driverString = "com.mysql.jdbc.Driver";
    private static String connectionString = "jdbc:mysql://47.103.86.32:3306/ytek"; //假设所连接的数据库名为jpetstore
    private static String username = "ytek";                                          //要正确输入自己的用户名和密码
    private static String password = "ZNhNSX2HET3r72Jc";
    public static Connection getConnection() throws Exception {
        Connection connection = null;
        try {
            Class.forName(driverString);
            connection = DriverManager.getConnection(connectionString,username,password);
        } catch (Exception e) {
            throw e;
        }
        return connection;
    }
    public static void closeStatement(Statement statement) throws Exception {
        statement.close();
    }
    public static void closePreparedStatement(PreparedStatement pStatement)
            throws Exception {
        pStatement.close();
    }
    public static void closeResultSet(ResultSet resultSet) throws Exception {
        resultSet.close();
    }
    public static void closeConnection(Connection connection) throws Exception {
        connection.close();
    }

	/* test the DB Connection
	public static void main(String[] args) throws Exception {
		Connection conn = DBUtil.getConnection();
		System.out.println(conn);
	}*/



}