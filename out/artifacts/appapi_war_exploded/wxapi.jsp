<%@ page import="com.yoom.appapi.DbManager" %>
<%@ page import="me.gacl.websocket.WebSocketServer" %>
<%@ page import="com.yoom.appapi.DBUtil" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" pageEncoding="UTF-8" %>
<%
    String terminalid=request.getParameter("terminalid");
    String random=request.getParameter("random");
    String command=request.getParameter("command");
    String memberid=request.getParameter("memberid");

    String json="{\"result\":\"success\",\"errmsg\":\"\"}";

    Connection conn= DBUtil.getConnection();

    if(terminalid==null||terminalid.equals("")||random==null||random.equals(""))
    {
        json="{\"result\":\"fail\",\"errmsg\":\"terminalid和random不能为空\"}";
    }
    else {
        try {

            String sql = " SELECT * FROM terminal where terminalid=? ";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(terminalid));
            ResultSet rs = ps.executeQuery();        //将查询的结果放入ResultSet结果集中
            String randomdb = "";
            /**
             * 从结果集ResultSet中迭代取出查询结果并输出
             */
            while (rs.next()) {
                randomdb = rs.getString("random");
            }

            if (randomdb.equals(random)) {
                boolean result =false;
                if(command.equals("opendoor")) {
                    result = WebSocketServer.sendMessageByTerminalId(terminalid, command);
                }
                else if(command.equals("exchangepoint"))
                {
                    String binid=request.getParameter("binid");
                }

                if (!result) {
                    json = "{\"result\":\"fail\",\"errmsg\":\"发送命令失败\"}";
                }
                else{
                    sql="update terminal set currentusememberid=?,currentusetime=NOW() where terminalid=? ";
                    PreparedStatement pstmt = (PreparedStatement) conn.prepareStatement(sql);
                    pstmt.setString(1, memberid);
                    pstmt.setInt(2, Integer.valueOf(terminalid));
                    int i = pstmt.executeUpdate();
                }
            } else {
                json = "{\"result\":\"fail\",\"errmsg\":\"terminalid和random不匹配\"}";
            }
        } catch (SQLException e) {
            json = "{\"result\":\"fail\",\"errmsg\":\"" + e.toString() + "\"}";
            e.printStackTrace();
        } finally {
            conn.close();
        }
    }



%><%=json%>