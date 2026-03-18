package com.java_project.reggie.controller;

import com.alibaba.fastjson.JSON;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.AiChatHistory;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.service.AIRecommendService;
import com.java_project.reggie.service.AiChatHistoryService;
import com.java_project.reggie.service.CategoryService;
import com.java_project.reggie.entity.Category;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 智能菜品推荐聊天助手
 * 基于关键词检索匹配，为用户推荐最合适的菜品
 */
@RestController
@RequestMapping("/ai")
@Slf4j
public class AIController {

    @Autowired
    private AIRecommendService aiRecommendService;
    
    @Autowired
    private AiChatHistoryService aiChatHistoryService;

    @Autowired
    private CategoryService categoryService;
    
    /**
     * 获取聊天历史
     */
    @GetMapping("/history")
    public R<List<AiChatHistory>> getChatHistory() {
        try {
            Long userId = BaseContext.getThreadLocal();
            if (userId == null) {
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
     * 聊天接口 - 智能菜品推荐
     */
    @PostMapping("/chat")
    public R<Map<String, Object>> chat(@RequestBody Map<String, String> map) {
        String message = map.get("message");
        
        if (StringUtils.isEmpty(message)) {
            return R.error("消息不能为空");
        }
        
        // 获取用户ID
        Long userId = null;
        try {
            userId = BaseContext.getThreadLocal();
        } catch (Exception e) {
            // 未登录
        }
        
        try {
            // 检索相关菜品
            List<Dish> relevantDishes = aiRecommendService.searchRelevantDishes(message);
            
            // 生成推荐回复
            String response = buildSmartResponse(message, relevantDishes);
            
            // 保存聊天历史
            if (userId != null) {
                try {
                    aiChatHistoryService.saveChatMessage(userId, "user", message, null);
                    String dishesJson = relevantDishes.isEmpty() ? null : JSON.toJSONString(relevantDishes);
                    aiChatHistoryService.saveChatMessage(userId, "ai", response, dishesJson);
                } catch (Exception ignore) {
                }
            }
            
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("answer", response);
            result.put("dishes", relevantDishes);
            
            return R.success(result);
            
        } catch (Exception e) {
            log.error("聊天异常", e);
            
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("answer", "😊 抱歉，系统暂时繁忙，请稍后再试~");
            result.put("dishes", java.util.Collections.emptyList());
            return R.success(result);
        }
    }
    
    /**
     * 根据检索到的菜品生成智能推荐回复
     */
    private String buildSmartResponse(String userMessage, List<Dish> dishes) {
        String lower = userMessage.toLowerCase();
        
        // 没有匹配到菜品
        if (dishes == null || dishes.isEmpty()) {
            return "😊 您好！我是智慧食堂小助手~\n\n" +
                   "暂时没有找到完全匹配的菜品，您可以试试：\n" +
                   "• 想吃什么口味？（辣/清淡/酸甜）\n" +
                   "• 想吃什么类型？（主食/炒菜/汤/套餐）\n" +
                   "• 或者说\"推荐几个菜\"让我为您挑选~";
        }
        
        // 构建推荐回复
        StringBuilder sb = new StringBuilder();
        
        // 根据用户意图选择不同的开场白
        if (lower.contains("推荐") || lower.contains("随便") || lower.contains("什么好")) {
            sb.append("😋 为您精心挑选了以下美食：\n\n");
        } else if (lower.contains("辣") || lower.contains("川") || lower.contains("麻")) {
            sb.append("🌶️ 为您找到了这些辣味美食：\n\n");
        } else if (lower.contains("清淡") || lower.contains("素") || lower.contains("健康")) {
            sb.append("🥗 为您推荐清淡健康的菜品：\n\n");
        } else if (lower.contains("汤") || lower.contains("喝")) {
            sb.append("🍲 为您找到了以下汤品：\n\n");
        } else if (lower.contains("便宜") || lower.contains("实惠") || lower.contains("经济")) {
            sb.append("💰 为您推荐性价比超高的菜品：\n\n");
        } else if (lower.contains("套餐") || lower.contains("营养")) {
            sb.append("🍱 为您推荐营养搭配的套餐：\n\n");
        } else if (lower.contains("早") || lower.contains("breakfast")) {
            sb.append("🌅 为您推荐元气早餐：\n\n");
        } else {
            sb.append("🍽️ 根据您的需求，为您推荐：\n\n");
        }
        
        // 最多展示5个菜品
        int limit = Math.min(dishes.size(), 5);
        for (int i = 0; i < limit; i++) {
            Dish dish = dishes.get(i);
            String price = String.format("%.0f", dish.getPrice().doubleValue() / 100.0);
            
            sb.append(i + 1).append(". **").append(dish.getName()).append("**");
            sb.append(" ¥").append(price);
            
            if (dish.getDescription() != null && !dish.getDescription().isEmpty()) {
                sb.append("\n   ").append(dish.getDescription());
            }
            
            // 获取分类名
            if (dish.getCategoryId() != null) {
                try {
                    Category cat = categoryService.getById(dish.getCategoryId());
                    if (cat != null) {
                        sb.append("\n   分类：").append(cat.getName());
                    }
                } catch (Exception ignore) {
                }
            }
            
            sb.append("\n\n");
        }
        
        // 结尾语
        if (dishes.size() > 5) {
            sb.append("还有更多好菜等您发现！😄\n");
        }
        sb.append("💡 您可以继续告诉我更具体的需求，我来帮您挑选~");
        
        return sb.toString();
    }
}
