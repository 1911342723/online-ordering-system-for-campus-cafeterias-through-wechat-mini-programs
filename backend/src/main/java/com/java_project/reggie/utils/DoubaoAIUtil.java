package com.java_project.reggie.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;

import javax.net.ssl.*;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.cert.X509Certificate;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 豆包AI工具类
 * 使用Java 17原生HttpClient
 */
@Slf4j
public class DoubaoAIUtil {

    private static final HttpClient httpClient = createHttpClient();

    private static HttpClient createHttpClient() {
        try {
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {}
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {}
                }
            };

            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

            return HttpClient.newBuilder()
                    .sslContext(sslContext)
                    .connectTimeout(Duration.ofSeconds(15))
                    .version(HttpClient.Version.HTTP_1_1)
                    .build();
        } catch (Exception e) {
            log.error("HttpClient初始化失败", e);
            return HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(15))
                    .build();
        }
    }

    /**
     * 调用豆包AI
     */
    public static String chat(String apiKey, String apiUrl, String model, String systemPrompt, String userMessage) {
        try {
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
            requestBody.put("max_tokens", 500);

            String jsonBody = JSON.toJSONString(requestBody);
            log.info("调用豆包AI，用户消息: {}", userMessage);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .timeout(Duration.ofSeconds(30))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                String responseBody = response.body();
                log.info("豆包AI响应: {}", responseBody);

                JSONObject jsonResponse = JSON.parseObject(responseBody);
                JSONArray choices = jsonResponse.getJSONArray("choices");

                if (choices != null && choices.size() > 0) {
                    JSONObject firstChoice = choices.getJSONObject(0);
                    JSONObject message = firstChoice.getJSONObject("message");
                    return message.getString("content");
                }
            }

            log.error("豆包AI调用失败，状态码: {}, 响应: {}", response.statusCode(), response.body());
            return "抱歉，AI助手暂时无法回答，请稍后再试。";

        } catch (Exception e) {
            log.error("调用豆包AI异常", e);
            return "抱歉，AI服务出现异常：" + e.getMessage();
        }
    }

    /**
     * 构建RAG提示词
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
