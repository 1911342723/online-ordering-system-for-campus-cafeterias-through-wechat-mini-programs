package com.java_project.reggie.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.java_project.reggie.service.LLMService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * LLM服务实现 — 接入豆包AI大语言模型
 *
 * 核心能力:
 * 1. 意图解析: 将用户自然语言输入解析为结构化的点餐意图（菜品类别、口味、忌口等）
 * 2. 推荐回复: 根据检索到的菜品，由LLM生成自然语言推荐文案
 * 3. 通用对话: 直接与LLM进行对话
 */
@Service
@Slf4j
public class LLMServiceImpl implements LLMService {

    @Value("${doubao.api-key}")
    private String apiKey;

    @Value("${doubao.api-url}")
    private String apiUrl;

    @Value("${doubao.model}")
    private String model;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * 意图解析的系统提示词
     * 指导LLM从用户输入中提取结构化的点餐意图
     */
    private static final String INTENT_PARSE_PROMPT =
        "你是一个校园食堂的智能点餐助手的意图解析模块。\n" +
        "请从用户输入中提取以下结构化信息，严格以JSON格式返回，不要添加任何其他文字说明：\n\n" +
        "{\n" +
        "  \"category\": \"菜品类别，如：面食、炒菜、汤、饮品、套餐、主食、烧烤等，无法判断则为空字符串\",\n" +
        "  \"taste\": \"口味偏好，如：辣、清淡、酸甜、麻辣、咸香等，无法判断则为空字符串\",\n" +
        "  \"restrictions\": [\"忌口列表，如：不要葱、不要蒜、不要香菜、不要辣等\"],\n" +
        "  \"priceRange\": \"价格偏好，如：便宜、实惠、适中、不限等，无法判断则为空字符串\",\n" +
        "  \"keywords\": [\"从输入中提取的核心搜索关键词列表，用于数据库检索\"],\n" +
        "  \"healthPreference\": \"健康偏好，如：低卡、高蛋白、低脂、减脂餐等，无法判断则为空字符串\"\n" +
        "}\n\n" +
        "注意事项：\n" +
        "- keywords应包含能直接用于菜品名称或描述搜索的具体词汇\n" +
        "- 如果用户说\"不加葱蒜\"，restrictions应为[\"不要葱\",\"不要蒜\"]\n" +
        "- 如果用户说\"清淡的\"，taste应为\"清淡\"\n" +
        "- 只输出JSON，不要输出其他任何内容";

    /**
     * 推荐回复的系统提示词
     */
    private static final String RECOMMENDATION_PROMPT =
        "你是一个校园食堂的贴心点餐助手，名叫\"食堂小助手\"。\n" +
        "请根据用户的需求和提供的菜品信息，为用户推荐合适的菜品。\n" +
        "回复要求：\n" +
        "1. 语气友好亲切，适当使用emoji\n" +
        "2. 推荐2-4道最匹配的菜品，说明推荐理由\n" +
        "3. 包含菜品名称、价格和简要描述\n" +
        "4. 如果用户有营养需求，简要说明菜品的营养特点\n" +
        "5. 如果用户有忌口，明确告知哪些菜品避开了忌口\n" +
        "6. 回复控制在200字以内，简洁明了\n" +
        "7. 价格单位是分，请转换为元展示（除以100）";


    @Override
    public Map<String, Object> parseUserIntent(String userQuery) {
        log.info("LLM意图解析，用户输入: {}", userQuery);

        try {
            String response = callDoubaoAPI(INTENT_PARSE_PROMPT, userQuery);

            if (response == null || response.isEmpty()) {
                log.warn("LLM返回空响应，使用本地回退解析");
                return fallbackParseIntent(userQuery);
            }

            // 提取JSON部分（LLM有时会在JSON外包裹markdown代码块）
            String jsonStr = extractJson(response);

            try {
                JSONObject json = JSON.parseObject(jsonStr);
                Map<String, Object> intent = new HashMap<>();
                intent.put("category", json.getString("category") != null ? json.getString("category") : "");
                intent.put("taste", json.getString("taste") != null ? json.getString("taste") : "");
                intent.put("priceRange", json.getString("priceRange") != null ? json.getString("priceRange") : "");
                intent.put("healthPreference", json.getString("healthPreference") != null ? json.getString("healthPreference") : "");

                // 解析数组字段
                JSONArray restrictionsArr = json.getJSONArray("restrictions");
                List<String> restrictions = new ArrayList<>();
                if (restrictionsArr != null) {
                    for (int i = 0; i < restrictionsArr.size(); i++) {
                        restrictions.add(restrictionsArr.getString(i));
                    }
                }
                intent.put("restrictions", restrictions);

                JSONArray keywordsArr = json.getJSONArray("keywords");
                List<String> keywords = new ArrayList<>();
                if (keywordsArr != null) {
                    for (int i = 0; i < keywordsArr.size(); i++) {
                        keywords.add(keywordsArr.getString(i));
                    }
                }
                intent.put("keywords", keywords);

                log.info("LLM意图解析结果: {}", intent);
                return intent;

            } catch (Exception parseEx) {
                log.warn("LLM返回JSON解析失败: {}，使用本地回退", parseEx.getMessage());
                return fallbackParseIntent(userQuery);
            }

        } catch (Exception e) {
            log.error("LLM意图解析调用异常: {}", e.getMessage());
            return fallbackParseIntent(userQuery);
        }
    }

    @Override
    public String generateRecommendationReply(String userQuery, String dishesInfo) {
        log.info("LLM生成推荐回复，用户查询: {}，菜品数据长度: {}", userQuery, dishesInfo.length());

        try {
            String prompt = String.format(
                "用户想要: %s\n\n以下是食堂当前可提供的菜品信息：\n%s\n\n" +
                "请根据用户需求，从上述菜品中推荐最合适的菜品，并说明推荐理由。",
                userQuery, dishesInfo
            );

            String response = callDoubaoAPI(RECOMMENDATION_PROMPT, prompt);

            if (response != null && !response.isEmpty()) {
                return response;
            }
        } catch (Exception e) {
            log.error("LLM生成推荐回复异常: {}", e.getMessage());
        }

        // 回退：返回通用回复
        return "😊 根据您的需求，为您找到了以上菜品，您可以直接点击查看详情~";
    }

    @Override
    public String chat(String systemPrompt, String userMessage) {
        return callDoubaoAPI(systemPrompt, userMessage);
    }

    /**
     * 调用豆包AI API
     */
    private String callDoubaoAPI(String systemPrompt, String userMessage) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            List<Map<String, String>> messages = new ArrayList<>();

            Map<String, String> systemMsg = new HashMap<>();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);
            messages.add(systemMsg);

            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userMessage);
            messages.add(userMsg);

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", model);
            requestBody.put("messages", messages);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 800);

            HttpEntity<String> entity = new HttpEntity<>(JSON.toJSONString(requestBody), headers);

            log.info("调用豆包AI，模型: {}，消息长度: {}", model, userMessage.length());

            ResponseEntity<String> response = restTemplate.exchange(
                apiUrl, HttpMethod.POST, entity, String.class
            );

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                JSONObject jsonResponse = JSON.parseObject(response.getBody());
                JSONArray choices = jsonResponse.getJSONArray("choices");
                if (choices != null && choices.size() > 0) {
                    JSONObject firstChoice = choices.getJSONObject(0);
                    JSONObject message = firstChoice.getJSONObject("message");
                    String content = message.getString("content");
                    log.info("豆包AI响应成功，回复长度: {}", content.length());
                    return content;
                }
            }

            log.error("豆包AI调用失败，状态码: {}", response.getStatusCode());
            return null;

        } catch (Exception e) {
            log.error("豆包AI调用异常: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 从LLM响应中提取JSON字符串
     * 处理LLM可能在JSON外包裹 ```json ... ``` 代码块的情况
     */
    private String extractJson(String response) {
        if (response == null) return "{}";

        String trimmed = response.trim();

        // 尝试去掉markdown代码块标记
        if (trimmed.startsWith("```json")) {
            trimmed = trimmed.substring(7);
        } else if (trimmed.startsWith("```")) {
            trimmed = trimmed.substring(3);
        }
        if (trimmed.endsWith("```")) {
            trimmed = trimmed.substring(0, trimmed.length() - 3);
        }

        return trimmed.trim();
    }

    /**
     * 本地回退意图解析（当LLM不可用时使用）
     * 基于关键词匹配的简单解析
     */
    private Map<String, Object> fallbackParseIntent(String userQuery) {
        Map<String, Object> intent = new HashMap<>();
        String lower = userQuery.toLowerCase();

        // 类别提取
        String category = "";
        if (lower.contains("面") || lower.contains("面条") || lower.contains("拉面")) category = "面食";
        else if (lower.contains("饭") || lower.contains("盖饭")) category = "盖饭";
        else if (lower.contains("汤") || lower.contains("粥")) category = "汤粥";
        else if (lower.contains("炒") || lower.contains("烧")) category = "炒菜";
        else if (lower.contains("饮") || lower.contains("茶") || lower.contains("奶茶")) category = "饮品";
        else if (lower.contains("套餐")) category = "套餐";
        intent.put("category", category);

        // 口味提取
        String taste = "";
        if (lower.contains("辣") || lower.contains("麻")) taste = "辣";
        else if (lower.contains("清淡") || lower.contains("素")) taste = "清淡";
        else if (lower.contains("酸")) taste = "酸";
        else if (lower.contains("甜")) taste = "甜";
        intent.put("taste", taste);

        // 忌口提取
        List<String> restrictions = new ArrayList<>();
        if (lower.contains("不要葱") || lower.contains("不加葱") || lower.contains("去葱")) restrictions.add("不要葱");
        if (lower.contains("不要蒜") || lower.contains("不加蒜") || lower.contains("去蒜")) restrictions.add("不要蒜");
        if (lower.contains("不要香菜") || lower.contains("不加香菜")) restrictions.add("不要香菜");
        if (lower.contains("不要辣") || lower.contains("不加辣") || lower.contains("不辣")) restrictions.add("不要辣");
        intent.put("restrictions", restrictions);

        // 价格偏好
        String priceRange = "";
        if (lower.contains("便宜") || lower.contains("实惠") || lower.contains("经济")) priceRange = "便宜";
        intent.put("priceRange", priceRange);

        // 健康偏好
        String healthPref = "";
        if (lower.contains("低卡") || lower.contains("减脂") || lower.contains("减肥")) healthPref = "低卡";
        else if (lower.contains("高蛋白") || lower.contains("增肌")) healthPref = "高蛋白";
        else if (lower.contains("健康") || lower.contains("营养")) healthPref = "健康";
        intent.put("healthPreference", healthPref);

        // 关键词提取（直接使用分词）
        List<String> keywords = new ArrayList<>();
        keywords.addAll(Arrays.asList(userQuery.split("[\\s,，。、！？!?]+")));
        keywords.removeIf(k -> k.length() < 1);
        intent.put("keywords", keywords);

        log.info("本地回退意图解析结果: {}", intent);
        return intent;
    }
}
