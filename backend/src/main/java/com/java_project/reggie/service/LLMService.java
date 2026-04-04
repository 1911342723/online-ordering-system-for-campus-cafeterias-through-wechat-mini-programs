package com.java_project.reggie.service;

import java.util.Map;

/**
 * 大语言模型(LLM)服务接口
 * 封装对豆包AI的调用，提供意图解析和智能回复生成能力
 */
public interface LLMService {

    /**
     * 解析用户自然语言输入，提取结构化的点餐意图
     *
     * @param userQuery 用户输入的自然语言（如"想吃不加葱蒜的清淡面条"）
     * @return 结构化意图 Map，包含:
     *   - category: 菜品类别（如"面食"）
     *   - taste: 口味偏好（如"清淡"）
     *   - restrictions: 忌口列表（如["不要葱","不要蒜"]）
     *   - priceRange: 价格偏好（如"便宜"）
     *   - keywords: 核心关键词列表
     */
    Map<String, Object> parseUserIntent(String userQuery);

    /**
     * 基于检索到的菜品信息，调用LLM生成个性化推荐回复
     *
     * @param userQuery 用户原始查询
     * @param dishesInfo 检索到的菜品信息文本
     * @return LLM生成的推荐回复
     */
    String generateRecommendationReply(String userQuery, String dishesInfo);

    /**
     * 直接调用LLM进行对话
     *
     * @param systemPrompt 系统提示词
     * @param userMessage 用户消息
     * @return LLM回复
     */
    String chat(String systemPrompt, String userMessage);
}
