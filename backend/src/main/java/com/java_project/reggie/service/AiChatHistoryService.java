package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.AiChatHistory;

import java.util.List;

/**
 * AI聊天历史服务接口
 */
public interface AiChatHistoryService extends IService<AiChatHistory> {
    
    /**
     * 获取用户的聊天历史（最近100条）
     * @param userId 用户ID
     * @return 聊天历史列表
     */
    List<AiChatHistory> getUserChatHistory(Long userId);
    
    /**
     * 保存聊天消息
     * @param userId 用户ID
     * @param role 角色（user/ai）
     * @param content 消息内容
     * @param dishes 推荐菜品JSON（可选）
     * @return 保存的记录
     */
    AiChatHistory saveChatMessage(Long userId, String role, String content, String dishes);
    
    /**
     * 删除7天前的聊天记录
     * @return 删除的记录数
     */
    int deleteOldMessages();
}

