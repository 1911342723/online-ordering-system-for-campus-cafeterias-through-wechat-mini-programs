package com.java_project.reggie.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * 豆包AI配置类
 */
@Configuration
@ConfigurationProperties(prefix = "doubao")
@Data
public class DoubaoConfig {
    
    /**
     * API密钥
     */
    private String apiKey;
    
    /**
     * API地址
     */
    private String apiUrl;
    
    /**
     * 模型名称
     */
    private String model;
}

