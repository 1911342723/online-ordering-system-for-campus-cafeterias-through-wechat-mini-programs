package com.java_project.reggie.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 订单WebSocket处理器
 * 用于实时推送新订单通知给商家端
 */
@Slf4j
@Component
public class OrderWebSocketHandler extends TextWebSocketHandler {

    // 存储商家ID和WebSocket会话的映射
    private static final Map<Long, WebSocketSession> merchantSessions = new ConcurrentHashMap<>();
    
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 从URL参数中获取商家ID
        String query = session.getUri().getQuery();
        Long merchantId = extractMerchantId(query);
        
        if (merchantId != null) {
            merchantSessions.put(merchantId, session);
            log.info("商家{}建立WebSocket连接", merchantId);
            
            // 发送连接成功消息
            Map<String, Object> connectedMsg = new HashMap<>();
            connectedMsg.put("type", "connected");
            connectedMsg.put("message", "WebSocket连接成功");
            sendMessage(session, connectedMsg);
        } else {
            log.warn("WebSocket连接缺少merchantId参数");
            session.close();
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.info("收到WebSocket消息: {}", message.getPayload());
        // 处理心跳等消息
        if ("ping".equals(message.getPayload())) {
            session.sendMessage(new TextMessage("pong"));
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        // 移除断开连接的会话
        merchantSessions.entrySet().removeIf(entry -> entry.getValue().equals(session));
        log.info("WebSocket连接关闭: {}", status);
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket传输错误", exception);
        merchantSessions.entrySet().removeIf(entry -> entry.getValue().equals(session));
    }

    /**
     * 向指定商家发送新订单通知
     */
    public static void sendNewOrderNotification(Long merchantId, Map<String, Object> orderData) {
        WebSocketSession session = merchantSessions.get(merchantId);
        if (session != null && session.isOpen()) {
            try {
                Map<String, Object> notification = new HashMap<>();
                notification.put("type", "new_order");
                notification.put("data", orderData);
                sendMessage(session, notification);
                log.info("已向商家{}发送新订单通知", merchantId);
            } catch (Exception e) {
                log.error("发送新订单通知失败", e);
            }
        } else {
            log.warn("商家{}未连接WebSocket，无法发送通知", merchantId);
        }
    }

    /**
     * 发送消息
     */
    private static void sendMessage(WebSocketSession session, Object message) {
        try {
            String json = objectMapper.writeValueAsString(message);
            session.sendMessage(new TextMessage(json));
        } catch (IOException e) {
            log.error("发送WebSocket消息失败", e);
        }
    }

    /**
     * 从查询参数中提取商家ID
     */
    private Long extractMerchantId(String query) {
        if (query == null || query.isEmpty()) {
            return null;
        }
        
        String[] params = query.split("&");
        for (String param : params) {
            String[] keyValue = param.split("=");
            if (keyValue.length == 2 && "merchantId".equals(keyValue[0])) {
                try {
                    return Long.parseLong(keyValue[1]);
                } catch (NumberFormatException e) {
                    log.error("解析merchantId失败: {}", keyValue[1]);
                    return null;
                }
            }
        }
        return null;
    }
}
