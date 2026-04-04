package com.java_project.reggie.controller;

import com.alibaba.fastjson.JSON;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.AiChatHistory;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.service.AIRecommendService;
import com.java_project.reggie.service.AiChatHistoryService;
import com.java_project.reggie.service.CategoryService;
import com.java_project.reggie.service.LLMService;
import com.java_project.reggie.service.impl.AIRecommendServiceImpl;
import com.java_project.reggie.entity.Category;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 智能菜品推荐聊天助手
 *
 * 核心流程:
 * 1. 用户输入自然语言需求（如"想吃不加葱蒜的清淡面条"）
 * 2. 调用LLM解析意图 → 提取类别(面食)、口味(清淡)、忌口(不要葱/不要蒜)
 * 3. 基于结构化意图检索匹配菜品
 * 4. 自动匹配口味选项（从dish_flavor表中找到对应忌口选项）
 * 5. 调用LLM根据检索结果生成自然语言推荐回复
 * 6. 返回推荐回复+菜品列表+自动匹配的口味选项
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

    @Autowired
    private LLMService llmService;

    /**
     * 获取聊天历史
     */
    @GetMapping("/history")
    public R<List<AiChatHistory>> getChatHistory() {
        try {
            Long userId = BaseContext.getThreadLocal();
            if (userId == null) {
                return R.success(Collections.emptyList());
            }
            List<AiChatHistory> history = aiChatHistoryService.getUserChatHistory(userId);
            return R.success(history);
        } catch (Exception e) {
            log.error("获取聊天历史失败", e);
            return R.success(Collections.emptyList());
        }
    }

    /**
     * 聊天接口 — 智能菜品推荐（集成LLM）
     *
     * 请求体: { "message": "想吃不加葱蒜的清淡面条" }
     *
     * 返回结构:
     * {
     *   "answer": "LLM生成的推荐回复文本",
     *   "dishes": [匹配的菜品列表],
     *   "intent": { 解析出的结构化意图 },
     *   "flavorOptions": { dishId: { "忌口": ["不要葱","不要蒜"] } }
     * }
     */
    @PostMapping("/chat")
    public R<Map<String, Object>> chat(@RequestBody Map<String, String> map) {
        String message = map.get("message");

        if (StringUtils.isEmpty(message)) {
            return R.error("消息不能为空");
        }

        Long userId = null;
        try {
            userId = BaseContext.getThreadLocal();
        } catch (Exception e) {
            // 未登录
        }

        try {
            // 1. 调用LLM解析用户意图
            Map<String, Object> intent = llmService.parseUserIntent(message);

            // 2. 基于意图检索相关菜品
            List<Dish> relevantDishes = aiRecommendService.searchRelevantDishes(message);

            // 3. 自动匹配口味选项
            List<String> restrictions = (List<String>) intent.getOrDefault("restrictions", new ArrayList<>());
            Map<Long, Map<String, List<String>>> flavorOptions = new HashMap<>();

            if (!restrictions.isEmpty() && aiRecommendService instanceof AIRecommendServiceImpl) {
                AIRecommendServiceImpl impl = (AIRecommendServiceImpl) aiRecommendService;
                for (Dish dish : relevantDishes) {
                    Map<String, List<String>> matched = impl.matchFlavorOptions(dish.getId(), restrictions);
                    if (!matched.isEmpty()) {
                        flavorOptions.put(dish.getId(), matched);
                    }
                }
            }

            // 4. 调用LLM生成推荐回复
            String response;
            if (!relevantDishes.isEmpty()) {
                String dishesInfo = aiRecommendService.formatDishesInfo(relevantDishes);
                response = llmService.generateRecommendationReply(message, dishesInfo);
            } else {
                response = "😊 您好！我是智慧食堂小助手~\n\n" +
                           "暂时没有找到完全匹配的菜品，您可以试试：\n" +
                           "• 想吃什么口味？（辣/清淡/酸甜）\n" +
                           "• 想吃什么类型？（主食/炒菜/汤/套餐）\n" +
                           "• 或者说\"推荐几个菜\"让我为您挑选~";
            }

            // 5. 保存聊天历史
            if (userId != null) {
                try {
                    aiChatHistoryService.saveChatMessage(userId, "user", message, null);
                    String dishesJson = relevantDishes.isEmpty() ? null : JSON.toJSONString(relevantDishes);
                    aiChatHistoryService.saveChatMessage(userId, "ai", response, dishesJson);
                } catch (Exception ignore) {
                    log.warn("保存聊天历史失败", ignore);
                }
            }

            // 6. 构建返回结果
            Map<String, Object> result = new HashMap<>();
            result.put("answer", response);
            result.put("dishes", relevantDishes);
            result.put("intent", intent);
            result.put("flavorOptions", flavorOptions);

            return R.success(result);

        } catch (Exception e) {
            log.error("聊天异常", e);

            Map<String, Object> result = new HashMap<>();
            result.put("answer", "😊 抱歉，系统暂时繁忙，请稍后再试~");
            result.put("dishes", Collections.emptyList());
            result.put("intent", Collections.emptyMap());
            result.put("flavorOptions", Collections.emptyMap());
            return R.success(result);
        }
    }
}
