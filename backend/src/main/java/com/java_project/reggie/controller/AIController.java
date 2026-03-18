package com.java_project.reggie.controller;

import com.alibaba.fastjson.JSON;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.config.DoubaoConfig;
import com.java_project.reggie.entity.AiChatHistory;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.service.AIRecommendService;
import com.java_project.reggie.service.AiChatHistoryService;
import com.java_project.reggie.utils.DoubaoAIUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * AI推荐控制器
 * 使用RAG（检索增强生成）技术，结合豆包AI提供智能菜品推荐
 */
@RestController
@RequestMapping("/ai")
@Slf4j
public class AIController {

    @Autowired
    private DoubaoConfig doubaoConfig;
    
    @Autowired
    private AIRecommendService aiRecommendService;
    
    @Autowired
    private AiChatHistoryService aiChatHistoryService;
    
    /**
     * 获取聊天历史
     * @return 聊天历史列表
     */
    @GetMapping("/history")
    public R<List<AiChatHistory>> getChatHistory() {
        try {
            Long userId = BaseContext.getThreadLocal();
            if (userId == null) {
                // 如果没有登录，返回空列表（不报错）
                return R.success(java.util.Collections.emptyList());
            }
            
            List<AiChatHistory> history = aiChatHistoryService.getUserChatHistory(userId);
            return R.success(history);
            
        } catch (Exception e) {
            log.error("获取聊天历史失败", e);
            return R.success(java.util.Collections.emptyList());
        }
    }
    
    /**
     * AI聊天接口 - 使用RAG推荐菜品
     * @param map 请求参数，包含message字段
     * @return AI回复
     */
    @PostMapping("/chat")
    public R<Map<String, Object>> chat(@RequestBody Map<String, String> map) {
        String message = map.get("message");
        
        if (StringUtils.isEmpty(message)) {
            return R.error("消息不能为空");
        }
        
        log.info("收到AI聊天请求，用户消息: {}", message);
        
        // 获取用户ID（如果已登录）
        Long userId = null;
        try {
            userId = BaseContext.getThreadLocal();
        } catch (Exception e) {
            // 未登录用户
        }
        
        try {
            // 步骤1: 使用RAG检索相关菜品
            List<Dish> relevantDishes = aiRecommendService.searchRelevantDishes(message);
            
            // 步骤2: 将菜品信息格式化为文本
            String dishesInfo = aiRecommendService.formatDishesInfo(relevantDishes);
            

            
            // 步骤3: 构建系统提示词
            String systemPrompt = "你是一个专业的智慧食堂AI助手，名字叫\"智慧小助手\"。" +
                    "你的任务是根据用户的需求和提供的菜品信息，为用户推荐最合适的菜品。" +
                    "请注意：\n" +
                    "1. 只推荐提供给你的菜品信息中的菜品\n" +
                    "2. 清晰说明每道菜为什么符合用户需求\n" +
                    "3. 语言要友好、简洁、吸引人\n" +
                    "4. 如果用户需求不明确，可以适当引导\n" +
                    "5. 回复要有表情符号，增加亲和力";
            
            // 步骤4: 构建完整的用户提示（包含RAG检索的菜品信息）
            String fullUserMessage = DoubaoAIUtil.buildRAGPrompt(message, dishesInfo);
            
            // 步骤5: 调用豆包AI
            String aiResponse = DoubaoAIUtil.chat(
                    doubaoConfig.getApiKey(),
                    doubaoConfig.getApiUrl(),
                    doubaoConfig.getModel(),
                    systemPrompt,
                    fullUserMessage
            );
            
            log.info("AI回复成功");
            
            // 保存聊天历史（如果用户已登录）
            if (userId != null) {
                try {
                    // 保存用户消息
                    aiChatHistoryService.saveChatMessage(userId, "user", message, null);
                    
                    // 保存AI回复（包含推荐菜品）
                    String dishesJson = relevantDishes.isEmpty() ? null : JSON.toJSONString(relevantDishes);
                    aiChatHistoryService.saveChatMessage(userId, "ai", aiResponse, dishesJson);
                    
                } catch (Exception e) {
                    log.error("保存聊天历史失败", e);
                }
            }
            
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("answer", aiResponse);
            result.put("dishes", relevantDishes);
            
            return R.success(result);
            
        } catch (Exception e) {
            log.error("AI聊天异常", e);
            
            // 降级方案：使用本地规则推荐
            String fallbackResponse = getFallbackResponse(message);
            
            // 保存降级响应到历史（如果用户已登录）
            if (userId != null) {
                try {
                    aiChatHistoryService.saveChatMessage(userId, "user", message, null);
                    aiChatHistoryService.saveChatMessage(userId, "ai", fallbackResponse, null);
                } catch (Exception ignore) {
                }
            }
            
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("answer", fallbackResponse);
            result.put("dishes", java.util.Collections.emptyList());
            
            return R.success(result);
        }
    }
    
    /**
     * 降级响应 - 当AI服务不可用时使用
     */
    private String getFallbackResponse(String message) {

        
        // 简单的规则匹配
        String lowerMessage = message.toLowerCase();
        
        if (lowerMessage.contains("辣") || lowerMessage.contains("川菜")) {
            return "🌶️ 推荐您尝试：\n\n" +
                   "1. **宫保鸡丁** - 经典川菜，鸡肉嫩滑，花生香脆\n" +
                   "2. **麻婆豆腐** - 麻辣鲜香，豆腐滑嫩入味\n\n" +
                   "这些菜品都是辣味十足，非常符合您的口味！";
        }
        
        if (lowerMessage.contains("清淡") || lowerMessage.contains("素")) {
            return "🥗 为您推荐清淡健康的菜品：\n\n" +
                   "1. **清炒时蔬** - 新鲜应季蔬菜，清爽营养\n" +
                   "2. **番茄蛋汤** - 酸甜可口，开胃解腻\n\n" +
                   "这些菜品都很清淡，适合健康饮食！";
        }
        
        if (lowerMessage.contains("营养") || lowerMessage.contains("套餐")) {
            return "🍱 推荐营养均衡套餐：\n\n" +
                   "**商务套餐** - 一荤一素+米饭+汤\n" +
                   "荤素搭配，营养全面，价格实惠！";
        }
        
        return "😊 我可以根据您的口味推荐美食哦！\n\n" +
               "请告诉我您喜欢：\n" +
               "• 什么口味？（辣/清淡/酸甜）\n" +
               "• 什么类型？（主食/炒菜/汤）\n" +
               "• 预算多少？\n\n" +
               "或者直接说\"随便推荐几个\"也可以~";
    }
}
