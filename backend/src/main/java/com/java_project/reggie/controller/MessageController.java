package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Message;
import com.java_project.reggie.service.MessageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 消息功能Controller
 */
@Slf4j
@RestController
@RequestMapping("/message")
public class MessageController {

    @Autowired
    private MessageService messageService;

    /**
     * 获取对话列表
     */
    @GetMapping("/conversations")
    public R<List<Map<String, Object>>> getConversations(@RequestParam Long merchantId) {
        log.info("获取商家{}的对话列表", merchantId);
        
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getMerchantId, merchantId);
        wrapper.orderByDesc(Message::getCreateTime);
        
        List<Message> messages = messageService.list(wrapper);
        
        // 按用户分组
        Map<Long, List<Message>> grouped = messages.stream()
                .collect(Collectors.groupingBy(Message::getUserId));
        
        List<Map<String, Object>> conversations = new ArrayList<>();
        
        grouped.forEach((userId, msgs) -> {
            Map<String, Object> conv = new HashMap<>();
            Message latest = msgs.get(0);
            
            conv.put("id", userId);
            conv.put("userId", userId);
            conv.put("userName", latest.getUserName());
            conv.put("lastMessage", latest.getContent());
            conv.put("lastMessageTime", latest.getCreateTime());
            conv.put("unreadCount", msgs.stream().filter(m -> !m.getFromMerchant() && m.getStatus() == 0).count());
            
            conversations.add(conv);
        });
        
        // 按最后消息时间排序
        conversations.sort((a, b) -> {
            Date timeA = (Date) a.get("lastMessageTime");
            Date timeB = (Date) b.get("lastMessageTime");
            return timeB.compareTo(timeA);
        });
        
        return R.success(conversations);
    }

    /**
     * 获取消息列表
     */
    @GetMapping("/list")
    public R<List<Message>> getMessages(
            @RequestParam Long merchantId,
            @RequestParam Long userId) {
        
        log.info("获取商家{}与用户{}的消息", merchantId, userId);
        
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getMerchantId, merchantId)
                .eq(Message::getUserId, userId)
                .orderByAsc(Message::getCreateTime);
        
        List<Message> messages = messageService.list(wrapper);
        
        // 标记商家收到的消息为已读
        messages.stream()
                .filter(m -> !m.getFromMerchant() && m.getStatus() == 0)
                .forEach(m -> {
                    m.setStatus(1);
                    messageService.updateById(m);
                });
        
        return R.success(messages);
    }

    /**
     * 发送消息
     */
    @PostMapping("/send")
    public R<String> sendMessage(@RequestBody Message message) {
        log.info("发送消息：{}", message);
        
        messageService.save(message);
        
        return R.success("发送成功");
    }

    /**
     * 标记已读
     */
    @PutMapping("/read")
    public R<String> markAsRead(@RequestBody Map<String, Object> params) {
        Long conversationId = Long.parseLong(params.get("conversationId").toString());
        
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getUserId, conversationId)
                .eq(Message::getFromMerchant, false)
                .eq(Message::getStatus, 0);
        
        List<Message> messages = messageService.list(wrapper);
        messages.forEach(m -> {
            m.setStatus(1);
            messageService.updateById(m);
        });
        
        return R.success("已标记为已读");
    }
}

