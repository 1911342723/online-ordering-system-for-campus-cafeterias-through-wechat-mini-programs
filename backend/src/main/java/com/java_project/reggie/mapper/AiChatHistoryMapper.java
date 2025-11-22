package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.AiChatHistory;
import org.apache.ibatis.annotations.Mapper;

/**
 * AI聊天历史Mapper
 */
@Mapper
public interface AiChatHistoryMapper extends BaseMapper<AiChatHistory> {
}

