package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.SystemConfig;
import java.util.Map;

/**
 * 系统配置服务接口
 */
public interface SystemConfigService extends IService<SystemConfig> {
    
    /**
     * 根据配置键获取配置值
     */
    String getConfigValue(String configKey);
    
    /**
     * 根据配置键获取配置值（带默认值）
     */
    String getConfigValue(String configKey, String defaultValue);
    
    /**
     * 获取Boolean类型配置
     */
    Boolean getBooleanConfig(String configKey, Boolean defaultValue);
    
    /**
     * 获取Integer类型配置
     */
    Integer getIntegerConfig(String configKey, Integer defaultValue);
    
    /**
     * 更新配置
     */
    boolean updateConfig(String configKey, String configValue);
    
    /**
     * 获取所有公开配置
     */
    Map<String, String> getAllPublicConfigs();
    
    /**
     * 获取指定分组的配置
     */
    Map<String, String> getConfigsByGroup(String configGroup);
}

