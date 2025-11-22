package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.AiChatHistory;
import com.java_project.reggie.mapper.AiChatHistoryMapper;
import com.java_project.reggie.service.AiChatHistoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * AI聊天历史服务实现
 */
@Service
@Slf4j
public class AiChatHistoryServiceImpl extends ServiceImpl<AiChatHistoryMapper, AiChatHistory> 
        implements AiChatHistoryService {
    
    @Override
    public List<AiChatHistory> getUserChatHistory(Long userId) {
        LambdaQueryWrapper<AiChatHistory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(AiChatHistory::getUserId, userId)
                    .orderByAsc(AiChatHistory::getCreateTime)
                    .last("LIMIT 100"); // 只返回最近100条
        
        return this.list(queryWrapper);
    }
    
    @Override
    public AiChatHistory saveChatMessage(Long userId, String role, String content, String dishes) {
        AiChatHistory chatHistory = new AiChatHistory();
        chatHistory.setUserId(userId);
        chatHistory.setRole(role);
        chatHistory.setContent(content);
        chatHistory.setDishes(dishes);
        chatHistory.setCreateTime(LocalDateTime.now());
        
        this.save(chatHistory);
        log.info("保存聊天记录：userId={}, role={}", userId, role);
        
        return chatHistory;
    }
    
    @Override
    public int deleteOldMessages() {
        LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
        
        LambdaQueryWrapper<AiChatHistory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.lt(AiChatHistory::getCreateTime, sevenDaysAgo);
        
        int count = (int) this.count(queryWrapper);
        if (count > 0) {
            this.remove(queryWrapper);
            log.info("定时任务：删除了{}条7天前的聊天记录", count);
        }
        
        return count;
    }
}

