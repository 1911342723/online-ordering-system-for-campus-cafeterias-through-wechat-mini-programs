package com.java_project.reggie.task;

import com.java_project.reggie.service.AiChatHistoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 聊天历史清理定时任务
 * 每天凌晨2点执行，删除7天前的聊天记录
 */
@Component
@Slf4j
public class ChatHistoryCleanupTask {
    
    @Autowired
    private AiChatHistoryService aiChatHistoryService;
    
    /**
     * 定时清理过期聊天记录
     * cron表达式：每天凌晨2点执行
     * 格式：秒 分 时 日 月 星期
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void cleanupOldChatHistory() {
        log.info("开始执行聊天历史清理任务...");
        
        try {
            int deletedCount = aiChatHistoryService.deleteOldMessages();
            log.info("聊天历史清理任务完成，共删除{}条记录", deletedCount);
        } catch (Exception e) {
            log.error("聊天历史清理任务执行失败", e);
        }
    }
}

