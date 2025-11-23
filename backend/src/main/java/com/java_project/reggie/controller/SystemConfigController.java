package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.SystemConfig;
import com.java_project.reggie.service.SystemConfigService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
    public R<String> updateConfig(@RequestBody SystemConfig config) {
        log.info("更新配置：{}={}", config.getConfigKey(), config.getConfigValue());
        boolean success = systemConfigService.updateConfig(config.getConfigKey(), config.getConfigValue());
        return success ? R.success("配置更新成功") : R.error("配置更新失败");
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

