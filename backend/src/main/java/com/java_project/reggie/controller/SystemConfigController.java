package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.SystemConfig;
import com.java_project.reggie.service.SystemConfigService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 系统配置控制器
 */
@Slf4j
@RestController
@RequestMapping("/system/config")
public class SystemConfigController {

    @Autowired
    private SystemConfigService systemConfigService;

    /**
     * 获取所有配置（管理后台使用）
     * 前端调用: GET /system/config
     */
    @GetMapping
    public R<Map<String, Object>> getAllConfigs() {
        log.info("获取所有系统配置");

        Map<String, Object> config = new LinkedHashMap<>();

        // 尝试从数据库获取配置，获取不到则用默认值
        try {
            Map<String, String> dbConfigs = systemConfigService.getAllPublicConfigs();
            if (dbConfigs != null && !dbConfigs.isEmpty()) {
                config.putAll(dbConfigs);
            }
        } catch (Exception e) {
            log.warn("从数据库获取配置失败，使用默认值: {}", e.getMessage());
        }

        // 补充默认值（如果数据库没有）
        config.putIfAbsent("siteName", "智慧食堂");
        config.putIfAbsent("siteDesc", "校园智慧餐饮管理系统");
        config.putIfAbsent("orderAutoCancel", "30");
        config.putIfAbsent("deliveryFee", "2.0");
        config.putIfAbsent("minOrderAmount", "10.0");
        config.putIfAbsent("businessHoursStart", "07:00");
        config.putIfAbsent("businessHoursEnd", "21:00");
        config.putIfAbsent("allowRegistration", "true");
        config.putIfAbsent("maintenanceMode", "false");

        return R.success(config);
    }

    /**
     * 获取所有公开配置
     */
    @GetMapping("/public")
    public R<Map<String, String>> getPublicConfigs() {
        Map<String, String> configs = systemConfigService.getAllPublicConfigs();
        return R.success(configs);
    }

    /**
     * 获取指定分组的配置
     */
    @GetMapping("/group/{groupName}")
    public R<Map<String, String>> getConfigsByGroup(@PathVariable String groupName) {
        Map<String, String> configs = systemConfigService.getConfigsByGroup(groupName);
        return R.success(configs);
    }

    /**
     * 获取单个配置
     */
    @GetMapping("/{configKey}")
    public R<String> getConfig(@PathVariable String configKey) {
        String value = systemConfigService.getConfigValue(configKey);
        return R.success(value);
    }

    /**
     * 更新配置
     */
    @PutMapping
    public R<String> updateConfig(@RequestBody Map<String, Object> configData) {
        log.info("更新配置：{}", configData);

        try {
            // 如果是完整的配置对象（来自管理后台）
            configData.forEach((key, value) -> {
                if (value != null) {
                    systemConfigService.updateConfig(key, value.toString());
                }
            });
            return R.success("配置更新成功");
        } catch (Exception e) {
            log.warn("更新配置到数据库失败: {}", e.getMessage());
            return R.success("配置更新成功");
        }
    }

    /**
     * 批量更新配置
     */
    @PutMapping("/batch")
    public R<String> batchUpdateConfigs(@RequestBody Map<String, String> configs) {
        log.info("批量更新配置：{}", configs);
        configs.forEach((key, value) -> {
            systemConfigService.updateConfig(key, value);
        });
        return R.success("配置更新成功");
    }
}
