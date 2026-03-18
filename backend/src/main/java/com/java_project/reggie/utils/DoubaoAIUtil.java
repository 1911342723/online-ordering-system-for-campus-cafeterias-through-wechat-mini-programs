package com.java_project.reggie.utils;

import dev.langchain4j.model.openai.OpenAiChatModel;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.data.message.SystemMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.output.Response;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

/**
 * 豆包AI工具类
 * 使用LangChain4j的OpenAI兼容客户端调用火山引擎豆包API
 */
@Slf4j
public class DoubaoAIUtil {

    /**
     * 调用豆包AI
     */
    public static String chat(String apiKey, String apiUrl, String model, String systemPrompt, String userMessage) {
        try {
            log.info("调用豆包AI，用户消息: {}", userMessage);

            // 从apiUrl中提取baseUrl（去掉 /chat/completions 部分）
            String baseUrl = apiUrl.replace("/chat/completions", "");

            // 使用LangChain4j的OpenAI兼容客户端
            OpenAiChatModel chatModel = OpenAiChatModel.builder()
                    .baseUrl(baseUrl)
                    .apiKey(apiKey)
                    .modelName(model)
                    .temperature(0.7)
                    .maxTokens(500)
                    .build();

            // 构建消息
            List<ChatMessage> messages = new ArrayList<>();
            messages.add(SystemMessage.from(systemPrompt));
            messages.add(UserMessage.from(userMessage));

            // 调用AI
            Response<AiMessage> response = chatModel.generate(messages);
            String aiReply = response.content().text();

            log.info("豆包AI响应: {}", aiReply);
            return aiReply;

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
