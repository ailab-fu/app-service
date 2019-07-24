<%@ page import="com.yoom.appapi.DbManager" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.yoom.appapi.DBUtil" %>
<%@ page import="com.fasterxml.jackson.databind.util.JSONPObject" %>
<%@ page import="com.yoom.appapi.JSONUtil" %>

<%@ page language="java" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    String action=request.getParameter("action");
    Statement stmt = null;
    ResultSet rs = null;

    String json="[{\"result\":\"success\",\"errmsg\":\"\"}]";


    if(action.equals("register"))
    {
        //String terminalid= request.getParameter("terminalid");//终端设备ID
        String machinecode= request.getParameter("machinecode");//机器码
        String latitudestr= request.getParameter("latitude");//纬度信息
        String longitudestr= request.getParameter("longitude");//经度信息
        String address= request.getParameter("address");//登记位置地址

        double latitude=0;
        if(latitudestr!=null&&!latitudestr.equals(""))
        {
            latitude=Double.valueOf(latitudestr);
        }
        double longitude=0;
        if(longitudestr!=null&&!longitudestr.equals(""))
        {
            longitude=Double.valueOf(longitudestr);
        }

        Connection conn=DBUtil.getConnection();
        try {
            CallableStatement cs = conn.prepareCall("{call registerTerminalInfo(?,?,?,?,?)}");
            cs.setString(1, machinecode);
            cs.setDouble(2, latitude);
            cs.setDouble(3, longitude);
            cs.setString(4, address);
            cs.registerOutParameter(5, Types.INTEGER);
            cs.executeUpdate();
            int terminalid=cs.getInt(5);
            json="[{\"result\":\"success\",\"errmsg\":\"\",\"terminalid\":\""+terminalid+"\"}]";

        } catch (SQLException e) {
            e.printStackTrace();
            json="[{\"result\":\"fail\",\"errmsg\":\""+e.toString()+"\"}]";
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
    else if(action.equals("getbinconfig"))
    {
        Connection conn=DBUtil.getConnection();
        String terminalid= request.getParameter("terminalid");//终端设备ID
        String sql = " select * from terminal_binstatus where terminalid=? and isvalid=1 ";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(terminalid));
        rs = ps.executeQuery();        //将查询的结果放入ResultSet结果集中
        String str="";
        while(rs.next())
        {
            if(str.length()>0) str+=",";
            str+="{\"binid\":\""+rs.getString("binid")+"\",\"weightport\":\""+rs.getString("weightport")+"\",\"distanceport\":\""+rs.getString("distanceport")+"\"}";
        }
        json= "["+str+"]";
    }
    else if(action.equals("uploadinfo"))
    {
        String machinecode= request.getParameter("machinecode");//机器码
        String random=request.getParameter("random");
        Connection conn=DBUtil.getConnection();

        int i = 0;
        String sql = "update terminal set random=? where machinecode=? ";
        PreparedStatement pstmt;
        try {
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            pstmt.setString(1, random);
            pstmt.setString(2, machinecode);
            i = pstmt.executeUpdate();
            pstmt.close();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
            json="[{\"result\":\"fail\",\"errmsg\":\""+e.toString()+"\"}]";
        }

        if(i<=0){
            json="[{\"result\":\"fail\",\"errmsg\":\"受影响的行数为0\"}]";
        }
    }
    else if(action.equals("uploaddistance"))
    {
            String terminalid= request.getParameter("terminalid");
            String binid=request.getParameter("binid");
            String distance=request.getParameter("distance");
            Connection conn=DBUtil.getConnection();

            int i = 0;
            String sql = "update terminal_binstatus set distance=? where terminalid=? and binid=? ";
            PreparedStatement pstmt;
            try {
                pstmt = (PreparedStatement) conn.prepareStatement(sql);
                pstmt.setDouble(1, Double.valueOf(distance));
                pstmt.setInt(2,  Integer.valueOf(terminalid) );
                pstmt.setInt(3, Integer.valueOf(binid));
                i = pstmt.executeUpdate();
                pstmt.close();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
                json="[{\"result\":\"fail\",\"errmsg\":\""+e.toString()+"\"}]";
            }

            if(i<=0){
                json="[{\"result\":\"fail\",\"errmsg\":\"受影响的行数为0\"}]";
            }
     }
    else if(action.equals("uploadweight"))
    {
        String terminalid= request.getParameter("terminalid");//终端设备ID
        String binid= request.getParameter("binid");
        String weight= request.getParameter("weight");//本次称重值
        String binweight= request.getParameter("binweight");//分箱体总重
        Connection conn=DBUtil.getConnection();
        try {
            CallableStatement cs = conn.prepareCall("{call uploadweight(?,?,?,?)}");
            cs.setInt(1,  Integer.valueOf(terminalid) );
            cs.setInt(2, Integer.valueOf(binid));
            cs.setInt(3, Integer.valueOf(weight));
            cs.setInt(4, Integer.valueOf(binweight));
            cs.executeUpdate();
            json="[{\"result\":\"success\",\"errmsg\":\"\"}]";

        } catch (SQLException e) {
            e.printStackTrace();
            json="[{\"result\":\"fail\",\"errmsg\":\""+e.toString()+"\"}]";
        } finally {
            DBUtil.closeConnection(conn);
        }
    }



%>

<%=json%>