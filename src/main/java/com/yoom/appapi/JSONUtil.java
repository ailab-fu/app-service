package com.yoom.appapi;

import org.json.JSONException;
import org.json.JSONObject;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

public class JSONUtil {
    /**
     * 将resultSet转化为JSONObject
     * @param rs
     * @return
     * @throws SQLException
     * @throws JSONException
     */

    public static String resultSetToJsonStr(ResultSet rs) throws Exception
    {
        // json对象
        JSONObject jsonObj = new JSONObject();
        // 获取列数
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();
        // 遍历ResultSet中的每条数据
        if (rs.next()) {
            // 遍历每一列
            for (int i = 1; i <= columnCount; i++) {
                String columnName =metaData.getColumnLabel(i);
                String value = rs.getString(columnName);
                jsonObj.put(columnName, value);
            }
        }
        return jsonObj.toString();
    }
}
