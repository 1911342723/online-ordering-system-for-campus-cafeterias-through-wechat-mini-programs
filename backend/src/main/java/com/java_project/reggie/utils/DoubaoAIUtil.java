package com.java_project.reggie.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 豆包AI工具类
 */
@Slf4j
public class DoubaoAIUtil {
    
    private static final RestTemplate restTemplate = new RestTemplate();
    
    /**
     * 调用豆包AI
     * @param apiKey API密钥
     * @param apiUrl API地址
     * @param model 模型名称
     * @param systemPrompt 系统提示
     * @param userMessage 用户消息
     * @return AI回复
     */
    public static String chat(String apiKey, String apiUrl, String model, String systemPrompt, String userMessage) {
        try {
            // 构建请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);
            
            // 构建消息列表
            List<Map<String, String>> messages = new ArrayList<>();
            
            // 添加系统消息
            Map<String, String> systemMsg = new HashMap<>();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);
            messages.add(systemMsg);
            
            // 添加用户消息
            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userMessage);
            messages.add(userMsg);
            
            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", model);
            requestBody.put("messages", messages);
            requestBody.put("temperature", 0.7); // 控制创造性
            requestBody.put("max_tokens", 500); // 最大token数
            
            // 创建请求实体
            HttpEntity<String> entity = new HttpEntity<>(JSON.toJSONString(requestBody), headers);
            
            log.info("调用豆包AI，消息长度: {}", userMessage.length());
            
            // 发送请求
            ResponseEntity<String> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.POST,
                entity,
                String.class
            );
            
            // 解析响应
            if (response.getStatusCode() == HttpStatus.OK) {
                String responseBody = response.getBody();
                log.info("豆包AI响应成功");
                
                JSONObject jsonResponse = JSON.parseObject(responseBody);
                JSONArray choices = jsonResponse.getJSONArray("choices");
                
                if (choices != null && choices.size() > 0) {
                    JSONObject firstChoice = choices.getJSONObject(0);
                    JSONObject message = firstChoice.getJSONObject("message");
                    return message.getString("content");
                }
            }
            
            log.error("豆包AI调用失败，状态码: {}", response.getStatusCode());
            return "抱歉，AI助手暂时无法回答，请稍后再试。";
            
        } catch (Exception e) {
            log.error("调用豆包AI异常", e);
            return "抱歉，AI服务出现异常：" + e.getMessage();
        }
    }
    
    /**
     * 构建RAG提示词
     * @param userQuery 用户查询
     * @param dishesInfo 菜品信息
     * @return 完整的提示词
     */
    public static String buildRAGPrompt(String userQuery, String dishesInfo) {
        return String.format(
            "用户想要: %s\n\n" +
            "以下是食堂当前可提供的菜品信息：\n%s\n\n" +
            "请根据用户需求，从上述菜品中推荐最合适的2-3道菜，" +
            "并详细说明为什么这些菜品符合用户的要求。" +
            "请用友好、简洁的语言回答，包含菜品名称、价格和推荐理由。",
            userQuery,
            dishesInfo
        );
    }
}

