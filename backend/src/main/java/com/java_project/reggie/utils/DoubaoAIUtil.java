package com.java_project.reggie.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;

import javax.net.ssl.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 豆包AI工具类
 * 使用原生HttpURLConnection + 自定义SSL，兼容Java 8
 */
@Slf4j
public class DoubaoAIUtil {

    private static final SSLSocketFactory sslSocketFactory;
    private static final HostnameVerifier hostnameVerifier;

    static {
        // 强制JVM使用TLS 1.2
        System.setProperty("https.protocols", "TLSv1.2");

        SSLSocketFactory tmpFactory = null;
        try {
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {}
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {}
                }
            };
            SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
            tmpFactory = sslContext.getSocketFactory();
            log.info("SSL初始化成功，协议: TLSv1.2");
        } catch (Exception e) {
            log.error("SSL初始化失败", e);
            tmpFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
        }
        sslSocketFactory = tmpFactory;
        hostnameVerifier = (hostname, session) -> true;
    }

    /**
     * 调用豆包AI（使用原生HttpURLConnection，不依赖RestTemplate）
     */
    public static String chat(String apiKey, String apiUrl, String model, String systemPrompt, String userMessage) {
        HttpURLConnection conn = null;
        try {
            // 构建消息列表
            List<Map<String, String>> messages = new ArrayList<>();

            Map<String, String> systemMsg = new HashMap<>();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);
            messages.add(systemMsg);

            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userMessage);
            messages.add(userMsg);

            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", model);
            requestBody.put("messages", messages);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 500);

            String jsonBody = JSON.toJSONString(requestBody);

            log.info("调用豆包AI，用户消息: {}", userMessage);

            // 创建连接
            URL url = new URL(apiUrl);
            conn = (HttpURLConnection) url.openConnection();

            // 如果是HTTPS，应用自定义SSL配置
            if (conn instanceof HttpsURLConnection) {
                HttpsURLConnection httpsConn = (HttpsURLConnection) conn;
                httpsConn.setSSLSocketFactory(sslSocketFactory);
                httpsConn.setHostnameVerifier(hostnameVerifier);
            }

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);
            conn.setDoOutput(true);
            conn.setDoInput(true);

            // 写入请求体
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
                os.flush();
            }

            // 读取响应
            int responseCode = conn.getResponseCode();
            InputStream inputStream = (responseCode >= 200 && responseCode < 300)
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            StringBuilder responseBuilder = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    responseBuilder.append(line);
                }
            }

            String responseBody = responseBuilder.toString();

            if (responseCode == 200) {
                log.info("豆包AI响应: {}", responseBody);
                JSONObject jsonResponse = JSON.parseObject(responseBody);
                JSONArray choices = jsonResponse.getJSONArray("choices");

                if (choices != null && choices.size() > 0) {
                    JSONObject firstChoice = choices.getJSONObject(0);
                    JSONObject message = firstChoice.getJSONObject("message");
                    return message.getString("content");
                }
            }

            log.error("豆包AI调用失败，状态码: {}, 响应: {}", responseCode, responseBody);
            return "抱歉，AI助手暂时无法回答，请稍后再试。";

        } catch (Exception e) {
            log.error("调用豆包AI异常", e);
            return "抱歉，AI服务出现异常：" + e.getMessage();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
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
