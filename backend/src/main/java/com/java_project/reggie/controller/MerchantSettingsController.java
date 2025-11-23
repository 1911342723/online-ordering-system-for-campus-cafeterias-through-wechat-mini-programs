package com.java_project.reggie.controller;

import com.java_project.reggie.common.AuthHelper;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.MerchantSettings;
import com.java_project.reggie.service.MerchantSettingsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 商家设置Controller
 */
@Slf4j
@RestController
@RequestMapping("/merchantSettings")
public class MerchantSettingsController {
    
    @Autowired
    private MerchantSettingsService settingsService;
    
    @Autowired
    private AuthHelper authHelper;
    
    /**
     * 获取当前商家的设置
     */
    @GetMapping
    public R<MerchantSettings> getSettings() {
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        MerchantSettings settings = settingsService.getOrCreate(merchantId);
        return R.success(settings);
    }
    
    /**
     * 更新商家设置
     */
    @PutMapping
    public R<String> updateSettings(@RequestBody MerchantSettings settings) {
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        // 确保只能修改自己的设置
        settings.setMerchantId(merchantId);
        
        MerchantSettings existing = settingsService.getByMerchantId(merchantId);
        if (existing != null) {
            settings.setId(existing.getId());
            settingsService.updateById(settings);
        } else {
            settingsService.save(settings);
        }
        
        log.info("商家{}更新设置: 自动接单={}", merchantId, settings.getAutoAcceptOrder());
        return R.success("设置已更新");
    }
    
    /**
     * 切换自动接单状态
     */
    @PutMapping("/toggleAutoAccept")
    public R<Boolean> toggleAutoAccept() {
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        MerchantSettings settings = settingsService.getOrCreate(merchantId);
        Integer newStatus = settings.getAutoAcceptOrder() == 1 ? 0 : 1;
        settings.setAutoAcceptOrder(newStatus);
        settingsService.updateById(settings);
        
        log.info("商家{}切换自动接单: {}", merchantId, newStatus == 1 ? "开启" : "关闭");
        return R.success(newStatus == 1);
    }
}

