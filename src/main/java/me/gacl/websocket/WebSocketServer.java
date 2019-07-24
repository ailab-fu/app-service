package me.gacl.websocket;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


import javax.servlet.http.HttpSession;
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * Created by jack on 2017/10/25.
 */
/**
 * websocket的具体实现类
 */
@ServerEndpoint(value = "/websocket/{terminalid}")
@Component
public class WebSocketServer {

    //静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。
    private static int onlineCount = 0;
    //concurrent包的线程安全Set，用来存放每个客户端对应的MyWebSocket对象。
    //private static CopyOnWriteArraySet<WebSocketServer> webSocketSet = new CopyOnWriteArraySet<WebSocketServer>();
    private static Map<String, WebSocketServer> clients = new ConcurrentHashMap<String, WebSocketServer>();
    //与某个客户端的连接会话，需要通过它来给客户端发送数据
    private Session session;
    private String terminalid;
    String str="";
    /**
     * 连接建立成功调用的方法
     */
    @OnOpen
    public void onOpen(@PathParam("terminalid")String terminalid, Session session, EndpointConfig config) {
        this.session = session;
        this.terminalid=terminalid;
        HttpSession httpSession= (HttpSession) config.getUserProperties().get(HttpSession.class.getName());
        //webSocketSet.add(this);     //加入set中
        if(!clients.containsKey(terminalid)) {
            clients.put(terminalid, this);
        }
        else
        {
            clients.remove(terminalid);
            clients.put(terminalid, this);
        }

        addOnlineCount();           //在线数加1
        try {
            //sendMessage(CommonConstant.CURRENT_WANGING_NUMBER.toString());
            sendMessage("服务端连接成功,terminalid:"+terminalid);
        } catch (IOException e) {
            System.out.println("IO异常");
        }
    }

    /**
     * 连接关闭调用的方法
     */
    @OnClose
    public void onClose() {
        //webSocketSet.remove(this);  //从set中删除
        clients.remove(terminalid);
        subOnlineCount();

        System.out.println("有一连接关闭！当前在线人数为" + getOnlineCount());

    }

    /**
     * 收到客户端消息后调用的方法
     *
     * @param message 客户端发送过来的消息
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        System.out.println("来自客户端的消息:" + message);
        str=message;
//        System.out.println("onMessage sessionId is : "+session.getId());
        //群发消息
//        for (WebSocketServer item : webSocketSet) {
//            try {
//                item.sendMessage(message);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
    }

    /**
     * 发生错误时调用
     */
    @OnError
    public void onError(Session session, Throwable error) {
        System.out.println("发生错误");
        error.printStackTrace();
    }

    public void sendMessage(String message) throws IOException {
        this.session.getBasicRemote().sendText("服务端消息:"+message);
        //this.session.getAsyncRemote().sendText(message);
    }

    public static boolean sendMessageByTerminalId(String terminalid,String message) throws IOException {
        WebSocketServer item = clients.get(terminalid);
        if (item != null) {
            item.session.getAsyncRemote().sendText(message);
            return true;
        }

        return false;

    }

    /**
     * 群发自定义消息
     */
    public static void sendInfo(String message) throws IOException {
        /*for (WebSocketServer item : webSocketSet) {
            try {
                item.sendMessage(message);
            } catch (IOException e) {
                continue;
            }
        }*/
    }

    public static synchronized int getOnlineCount() {
        return onlineCount;
    }

    public static synchronized void addOnlineCount() {
        WebSocketServer.onlineCount++;
    }

    public static synchronized void subOnlineCount() {
        WebSocketServer.onlineCount--;
    }
}
